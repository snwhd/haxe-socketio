package socketio;

import thx.Set;


typedef BroadcastOptions = {
    rooms: Set<Room>,
    ?except: Set<Room>,
}


class Adapter {

    private var rooms: Map<Room, Set<SessionID>> = [];
    private var sids: Map<SessionID, Set<Room>> = [];
    private var namespace: Namespace;

    public function new(namespace: Namespace) {
        this.namespace = namespace;
    }

    public function init() {
    }

    public function close() {
        this.namespace.server.closeSession(this.sids.keys());
        this.rooms = [];
        this.sids = [];
    }

    //
    // add/remove sessions
    //

    public function enter(sid: SessionID, rooms: Array<Room>) {
        var roomSet = this.sids.get(sid);
        if (roomSet == null) {
            roomSet = Set.createString();
            this.sids[sid] = roomSet;
        }

        for (room in rooms) {
            var sessions = this.rooms.get(room);
            if (sessions == null) {
                sessions = Set.createString();
                this.rooms[room] = sessions;
                this.namespace.handleEvent(null, "create-room", {
                    room: room,
                });
            }

            if (!sessions.exists(sid)) {
                sessions.add(sid);
                this.namespace.handleEvent(sid, "join-room", {
                    room: room,
                });
            }
        }
    }

    public function leave(sid: SessionID, rooms: Array<Room>) {
        var roomSet = this.sids.get(sid);

        for (room in rooms) {
            if (roomSet != null) {
                roomSet.remove(room);
            }
            this.deleteFromRoom(room, sid);
        }
    }

    public function leaveAll(sid: SessionID) {
        var roomSet = this.sids.get(sid);
        if (roomSet != null) {
            for (room in roomSet) {
                this.deleteFromRoom(room, sid);
            }
            this.sids.remove(sid);
        }
    }

    private function deleteFromRoom(room: Room, sid: SessionID) {
        var sessions = this.rooms.get(room);
        if (sessions != null) {
            if (sessions.remove(sid)) {
                this.namespace.handleEvent(sid, "leave-room", {
                    room: room,
                });
            }
            if (sessions.length == 0 && this.rooms.remove(room)) {
                this.namespace.handleEvent(null, "create-room", {
                    room: room,
                });
            }
        }
    }

    //
    // send packets
    //

    public function broadcast(
        packet: Packet,
        options: BroadcastOptions,
        ?flags: Dynamic // TODO: flags
    ): Void {
        packet.namespace = this.namespace.name;
        var data = packet.encode();
        this.apply(options, function (sid) {
            this.namespace.server.sendString(sid, data);
        });
    }

    private function apply(
        options: BroadcastOptions,
        callback: (SessionID) -> Void
    ): Void {
        var globalBroadcast = options.rooms.length == 0;
        if (globalBroadcast) {
            for (sid in this.sids.keys()) {
                if (options.except.exists(sid)) continue;
                callback(sid);
            }
        } else {
            var sent = Set.createString();
            for (room in options.rooms) {
                var sessions = this.rooms.get(room);
                if (sessions != null) for (sid in sessions) {
                    if (!sent.exists(sid)) {
                        sent.add(sid);
                        callback(sid);
                    }
                }
            }
        }
    }

}

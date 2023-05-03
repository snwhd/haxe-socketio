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
        throw "TODO";
    }

    public function close() {
        throw "TODO";
    }

    //
    // add/remove sessions
    //

    public function add(sid: SessionID, rooms: Array<Room>) {
        this.addAll(sid, rooms);
    }

    public function addAll(sid: SessionID, rooms: Array<Room>) {
        var roomSet = this.sids.get(sid);
        if (roomSet == null) {
            roomSet = Set.createString();
            this.sids[sid]  = roomSet;
        }

        for (room in rooms) {
            var sessions = this.rooms.get(room);
            if (sessions == null) {
                sessions = Set.createString();
                this.rooms[room] = sessions;
                // TODO: emit create-room
            }

            if (!sessions.exists(sid)) {
                sessions.add(sid);
                // TODO: emit join-room
            }
        }
    }

    public function del(sid: SessionID, room: Room) {
        var roomSet = this.sids.get(sid);
        if (roomSet != null) {
            roomSet.remove(sid);
        }

        this.deleteFromRoom(room, sid);
    }

    public function delAll(sid: SessionID) {
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
                // TODO: emit leave-room
            }
            if (sessions.length == 0 && this.rooms.remove(room)) {
                // TODO: emit delete-room
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
            trace('to(${sid}): $data');
        });
    }

    private function apply(
        options: BroadcastOptions,
        callback: (SessionID) -> Void
    ): Void {
        var globalBroadcast = options.rooms.length == 0;
        if (globalBroadcast) {
            for (sid in this.sids) {
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

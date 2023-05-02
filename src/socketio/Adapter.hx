package socketio;

import thx.Set;


typedef BroadcastOptions = {
    rooms: Set<Room>,
    ?except: Set<Room>,
}


class Adapter {

    private var rooms: Map<Room, Set<SocketID>> = [];
    private var sids: Map<SocketID, Set<Room>> = [];
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
    // add/remove sockets
    //

    public function add(sid: SocketID, rooms: Array<Room>) {
        this.addAll(sid, rooms);
    }

    public function addAll(sid: SocketID, rooms: Array<Room>) {
        var roomSet = this.sids.get(sid);
        if (roomSet == null) {
            roomSet = Set.createString();
            this.sids[sid]  = roomSet;
        }

        for (room in rooms) {
            var socketSet = this.rooms.get(room);
            if (socketSet == null) {
                socketSet = Set.createString();
                this.rooms[room] = socketSet;
                // TODO: emit create-room
            }

            if (!socketSet.exists(sid)) {
                socketSet.add(sid);
                // TODO: emit join-room
            }
        }
    }

    public function del(sid: SocketID, room: Room) {
        var roomSet = this.sids.get(sid);
        if (roomSet != null) {
            roomSet.remove(sid);
        }

        this.deleteFromRoom(room, sid);
    }

    public function delAll(sid: SocketID) {
        var roomSet = this.sids.get(sid);
        if (roomSet != null) {
            for (room in roomSet) {
                this.deleteFromRoom(room, sid);
            }
            this.sids.remove(sid);
        }
    }

    private function deleteFromRoom(room: Room, sid: SocketID) {
        var socketSet = this.rooms.get(room);
        if (socketSet != null) {
            if (socketSet.remove(sid)) {
                // TODO: emit leave-room
            }
            if (socketSet.length == 0 && this.rooms.remove(room)) {
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
        var data = packet.encode();
        this.apply(options, function (socket) {
            // TODO: send
            // socket.sendStringMessage(data)
            trace('to(${socket.id}): $data');
        });
    }

    private function apply(
        options: BroadcastOptions,
        callback: (Socket) -> Void
    ): Void {
        var globalBroadcast = options.rooms.length == 0;
        if (globalBroadcast) {
            for (sid in this.sids) {
                if (options.except.exists(sid)) continue;
                var socket = this.getSocket(sid);
                if (socket != null) callback(socket);
            }
        } else {
            var sent = Set.createString();
            for (room in options.rooms) {
                var socketSet = this.rooms.get(room);
                if (socketSet != null) for (sid in socketSet) {
                    if (!sent.exists(sid)) {
                        sent.add(sid);
                        var socket = this.getSocket(sid);
                        if (socket != null) callback(socket);
                    }
                }
            }
        }
    }

    private function getSocket(sid: SocketID): Socket {
        return this.namespace.sockets.get(sid);
    }

}

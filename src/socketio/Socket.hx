package socketio;

import haxe.ds.Either;


class Socket {

    public var id (default, null): SocketID;
    private var adapter: Adapter;

    public function new(id: SocketID, adapter: Adapter) {
        this.adapter = adapter;
        this.id = id;
    }

    public function join(r: OneOf<Room, Array<Room>>) {
        var rooms = switch (r) {
            case Left(room): [room];
            case Right(array): array;
        }
        this.adapter.addAll(this.id, rooms);
    }

}

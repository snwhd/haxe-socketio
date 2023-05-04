package socketio;

import haxe.ds.Either;
import thx.Set;


class BroadcastOperator {

    private var rooms: Map<Room, Bool> = [];
    private var adapter: Adapter;

    public function new(adapter: Adapter) {
        this.adapter = adapter;
    }

    public static function create(target: OneOf<Adapter, Namespace>): BroadcastOperator {
        return switch (target) {
            case Left(adapter): new BroadcastOperator(adapter);
            case Right(namespace): new BroadcastOperator(namespace.adapter);
        }
    }

    //
    // chaining
    //

    public function to(rooms: OneOf<Room, Array<Room>>) {
        switch (rooms) {
            case Left(room):
                this.rooms[room] = true;
            case Right(rooms):
                for (room in rooms) {
                    this.rooms[room] = true;
                }
        }
        return this;
    }

    public function except(rooms: Array<Room>) {
        for (room in rooms) {
            this.rooms[room] = false;
        }
        return this;
    }

    //
    // events
    //

    public function timeout(ms: Int) {
        throw "TODO";
    }

    public function emit(eventName: String, args: Dynamic) {
        var opts = {
            rooms: Set.createString(),
            except: Set.createString(),
        };

        for (room => include in  this.rooms.keyValueIterator()) {
            if (include) {
                opts.rooms.add(room);
            } else {
                opts.rooms.add(room);
            }
        }

        var packet = new Packet(EVENT, [eventName, args]);
        this.adapter.broadcast(packet, opts);
    }

    public function emitWithAck(eventName: String, args: Dynamic) {
        throw "TODO";
    }

}

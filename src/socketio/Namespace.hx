package socketio;

typedef Middleware = Dynamic;

typedef EventListener = (Socket, Dynamic) -> Void;


class Namespace {

    public var adapter: Adapter;
    public var name (default, null): String;
    public var sockets: Map<String, Socket> = [];

    private var middlewares: Array<Middleware>;
    private var handlers: Map<String, Array<EventListener>>;

    public function new(name: String) {
        this.adapter = new Adapter(this);
        this.name = name;
    }

    //
    // sockets
    //

    public function addSocket(socket: Socket) {
        this.sockets[socket.id] = socket;
    }

    public function fetchSockets(): Array<Socket> {
        throw "TODO";
    }

    public function socketsJoin(rooms: Array<String>) {
        throw "TODO";
    }

    public function socketsLeave(rooms: Array<String>) {
        throw "TODO";
    }

    // disconnect all sockets, optionally close underlying connection
    public function disconnectSockets(?close=false) {
        throw "TODO";
    }

    //
    // emit events
    //

    // emit an event to all connected clients
    public function emit(eventName: String, args: Dynamic) {
        BroadcastOperator.create(this).emit(eventName, args);
    }

    public function emitWithAck(eventName: String, args: Dynamic) {
        BroadcastOperator.create(this).emitWithAck(eventName, args);
    }

    //
    // middleware
    //

    public function use(middleware: Middleware) {
        this.middlewares.push(middleware);
    }

    //
    // broadcast operations
    //

    public function on(event: String, listener: EventListener) {
        if (!this.handlers.exists(event)) {
            this.handlers[event] = [];
        }
        this.handlers[event].push(listener);
    }

    public function to(rooms: Array<Room>): BroadcastOperator {
        return BroadcastOperator.create(this).to(rooms);
    }

    public function except(rooms: Array<Room>): BroadcastOperator {
        return BroadcastOperator.create(this).except(rooms);
    }

    public function timeout(ms: Int): BroadcastOperator {
        throw "TODO";
    }

}

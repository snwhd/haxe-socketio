package socketio;

import thx.Set;

typedef Middleware = Dynamic;
typedef EventListener = (SessionID, Dynamic) -> Void;
typedef CatchAllEventListener = (String, SessionID, Dynamic) -> Void;


class Namespace {

    public var name (default, null): String;
    public var adapter: Adapter;
    public var server: Server;

    private var handlers: Map<String, Array<EventListener>> = [];
    private var catchAll: Array<CatchAllEventListener> = [];
    private var middlewares: Array<Middleware> = [];

    public var sessions: Set<SessionID>;

    public function new(server: Server, name: String) {
        this.sessions = Set.createString();
        this.adapter = new Adapter(this);
        this.server = server;
        this.name = name;
    }

    //
    // sessions
    //

    public function addSession(session: SessionID) {
        this.sessions.add(session);
        this.adapter.addAll(session, [session]);
    }

    public function allJoin(rooms: Array<String>) {
        throw "TODO";
    }

    public function allLeave(rooms: Array<String>) {
        throw "TODO";
    }

    public function disconnectAll(?close=false) {
        throw "TODO";
    }

    //
    // events
    //

    // emit an event to all connected clients
    public function emit(eventName: String, args: Dynamic) {
        BroadcastOperator.create(this).emit(eventName, args);
    }

    public function emitWithAck(eventName: String, args: Dynamic) {
        BroadcastOperator.create(this).emitWithAck(eventName, args);
    }

    public function on(event: String, listener: EventListener) {
        if (!this.handlers.exists(event)) {
            this.handlers[event] = [];
        }
        this.handlers[event].push(listener);
    }

    public function onCatchAll(listener: CatchAllEventListener) {
        this.catchAll.push(listener);
    }

    public function handleEvent(
        sid: SessionID,
        event: String,
        data: Dynamic
    ): Void {
        // TODO: are multiple handlers per event actually supported?
        var handlers = this.handlers.get(event);
        if (handlers != null && handlers.length > 0) {
            for (handler in handlers) {
                handler(sid, data);
            }
        } else {
            for (handler in this.catchAll) {
                handler(event, sid, data);
            }
        }
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

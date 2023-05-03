package socketio;

import engineio.Server.ClientInfo as EngineioClientInfo;
import engineio.StringOrBinary;

import thx.Set;
import thx.Tuple;


typedef ClientInfo = {
    eio: EngineioClientInfo,
    sid: SessionID,
}


class Server {

    private static var SID_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYA0123456789";

    private var engine: engineio.Server;
    private var namespaces: Map<String, Namespace> = [];

    private var sessions: Map<SessionID, ClientInfo> = [];
    private var eioToSio: Map<SessionID, Array<Tuple2<SessionID, String>>> = [];

    public var debug = true;

    public function new() {
        this.engine = new engineio.Server(null, "/socket.io/");
        this.engine.onOpened = this.engineOpened;
        this.engine.onUpgraded = this.engineUpgraded;
        this.engine.onMessage = this.engineMessage;
        this.engine.onClosed = this.engineClosed;

        this.engine.debug = this.debug;
        this.engine.startMainThread();
        this.engine.startWebsocketThread();
    }

    //
    // public api
    //

    public function sendString(sid: SessionID, data: String) {
        var client = this.sessions.get(sid);
        if (client != null) {
            this.engine.sendStringMessage(client.eio, data);
        }
    }

    //
    // packet handling
    //

    private function handlePacket(
        eioClient: EngineioClientInfo,
        packet: Packet
    ): Void {
        _debug('Handling Packet from ${eioClient.sid} ${packet.type}');
        switch (packet.type) {
            case CONNECT:       this.handleConnect(eioClient, packet);
            case DISCONNECT:    this.handleDisconnect(eioClient, packet);
            case EVENT:         this.handleEvent(eioClient, packet);
            case ACK:           this.handleAck(eioClient, packet);
            case CONNECT_ERROR: this.handleConnect_error(eioClient, packet);
            case BINARY_EVENT:  this.handleBinary_event(eioClient, packet);
            case BINARY_ACK:    this.handleBinary_ack(eioClient, packet);
        }
    }


    private function handleConnect(
        eioClient: EngineioClientInfo,
        packet: Packet
    ): Void {
        var namespace = this.getOrCreateNamespace(packet.namespace);
        var client = this.getOrCreateClient(eioClient, namespace);
        var sid = client.sid;

        // TODO: middlewares

        var packet = new Packet(CONNECT, {sid: sid});
        this.engine.sendStringMessage(eioClient, packet.encode());
    }

    private function handleDisconnect(
        eioClient: EngineioClientInfo,
        packet: Packet
    ): Void {
    }

    private function handleEvent(
        eioClient: EngineioClientInfo,
        packet: Packet
    ): Void {
    }

    private function handleAck(
        eioClient: EngineioClientInfo,
        packet: Packet
    ): Void {
    }

    private function handleConnect_error(
        eioClient: EngineioClientInfo,
        packet: Packet
    ): Void {
    }

    private function handleBinary_event(
        eioClient: EngineioClientInfo,
        packet: Packet
    ): Void {
    }

    private function handleBinary_ack(
        eioClient: EngineioClientInfo,
        packet: Packet
    ): Void {
    }

    //
    // engine.io callbacks
    //

    private function engineOpened(client: EngineioClientInfo) {
    }

    private function engineUpgraded(client: EngineioClientInfo) {
    }

    private function engineMessage(client: EngineioClientInfo, message: StringOrBinary) {
        switch (message) {
            case PString(s):
                try {
                    var packet = Packet.decode(s);
                    this.handlePacket(client, packet);
                } catch (err) {
                    _debug('error handling packet: $err');
                    // TODO: close client
                    return;
                }
            case PBinary(b):
                throw "TODO: binary";
        }
    }

    private function engineClosed(sid: String) {
    }

    //
    // util
    //

    private inline function _debug(s: String) {
        #if debug
        if (this.debug) trace(s);
        #end
    }

    private function generateSid(): SessionID {
        function nextSid() {
            var sid = "";
            for (i in 0 ... 20) {
                var j = Math.floor(Math.random() * SID_CHARS.length);
                sid += SID_CHARS.charAt(j);
            }
            return sid;
        }

        var sid = nextSid();
        while (this.sessions.exists(sid)) {
            sid = nextSid();
        }

        return sid;
    }

    private function getOrCreateClient(
        eioClient: EngineioClientInfo,
        namespace: Namespace
    ): ClientInfo {
        var clientInfo: ClientInfo;

        var sessionIds = this.eioToSio.get(eioClient.sid);
        if (sessionIds != null) {
            for (pair in sessionIds) {
                if (pair.right == namespace.name) {
                    return this.sessions[pair.left];
                }
            }
        }

        // new namespace connection
        var sid = this.generateSid();
        _debug('Creating New Session: ${sid} (${eioClient.sid}, ${namespace.name})');

        clientInfo = {
            sid: sid,
            eio: eioClient,
        };

        if (sessionIds != null) {
            // existing websocket connection
            sessionIds.push(new Tuple2(sid, namespace.name));
        } else {
            // totally new client
            this.eioToSio[eioClient.sid] = [new Tuple2(sid, namespace.name)];
        }

        return clientInfo;
    }

    private function getOrCreateNamespace(name: String) {
        var namespace = this.namespaces.get(name);
        if (namespace == null) {
            _debug('Creating Namespace: $name');
            namespace = new Namespace(this, name);
            this.namespaces[name] = namespace;
        }
        return namespace;
    }

}

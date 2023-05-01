package socketio;

import engineio.Server.ClientInfo as EngineioClientInfo;
import engineio.StringOrBinary;


typedef Room = Dynamic;       // TODO
typedef Handler = Dynamic;    // TODO
typedef Middleware = Dynamic; // TODO

typedef Namespace = {
    rooms: Map<String, Room>,
    handlers: Map<String, Array<Handler>>,
    middlewares: Array<Middleware>,
}

typedef Socket = Dynamic; // TODO


class Server {

    private var engine: engineio.Server;
    private var namespaces: Map<String, Namespace> = [];

    public var debug = true;


    public function new() {
        this.engine = new engineio.Server();
        this.engine.onOpened = this.engineOpened;
        this.engine.onUpgraded = this.engineUpgraded;
        this.engine.onMessage = this.engineMessage;
        this.engine.onClosed = this.engineClosed;
    }

    private function handlePacket(
        eioClient: EngineioClientInfo,
        packet: Packet
    ): Void {
        _debug('received packet: ${packet.type}');
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

}

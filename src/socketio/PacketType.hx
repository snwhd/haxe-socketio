package socketio;


enum abstract PacketType(Int) from Int to Int {

    var CONNECT       = 0;
    var DISCONNECT    = 1;
    var EVENT         = 2;
    var ACK           = 3;
    var CONNECT_ERROR = 4;
    var BINARY_EVENT  = 5;
    var BINARY_ACK    = 6;

    @:to
    public static function toString(type: PacketType): String {
        return switch (type) {
            case CONNECT:       "CONNECT";
            case DISCONNECT:    "DISCONNECT";
            case EVENT:         "EVENT";
            case ACK:           "ACK";
            case CONNECT_ERROR: "CONNECT_ERROR";
            case BINARY_EVENT:  "BINARY_EVENT";
            case BINARY_ACK:    "BINARY_ACK";
        }
    }

    @:from
    public static function fromString(type: String): PacketType {
        return switch (type.toLowerCase()) {
            case "connect":       CONNECT;
            case "disconnect":    DISCONNECT;
            case "event":         EVENT;
            case "ack":           ACK;
            case "connect_error": CONNECT_ERROR;
            case "binary_event":  BINARY_EVENT;
            case "binary_ack":    BINARY_ACK;
            default: throw 'Invalid PacketType';
        }
    }

}

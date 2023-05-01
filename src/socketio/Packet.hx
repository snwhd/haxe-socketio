package socketio;


class Packet {

    private static var nextAckId = 1;

    public var type (default, null): PacketType;
    public var namespace (default, null) = "/";
    public var ackNumber (default, null): Null<Int> = null;

    public var json (default, null): Dynamic;

    public var nAttachments: Int = 0;
    public var attachments: Array<haxe.io.Bytes>;

    public function new(
        type: PacketType,
        ?json: Dynamic,
        ?namespace: String,
        ?ackNumber: Int,
        ?nAttachments: Int,
        ?attachments: Array<haxe.io.Bytes>,
        ?requestAck = false
    ): Void {
        this.type = type;
        this.json = json;
        this.nAttachments = nAttachments;
        this.attachments = attachments;
        if (
            this.attachments != null &&
            this.attachments.length != nAttachments
        ) {
            throw "attachment length mismatch";
        }
        if (namespace != null) {
            this.namespace = namespace;
        }

        this.ackNumber = ackNumber;
        if (ackNumber == null && requestAck) {
            this.ackNumber = Packet.nextAckId++;
        }
    }

    public function encode(b64=false) : String {
        var typeInt: Int = this.type;
        var nAttachments = "";
        if (this.attachments != null && this.attachments.length > 0) {
            throw "TODO: binary support";
            nAttachments = Std.string(this.attachments.length) + "-";
        }

        var namespace = this.namespace + ",";
        if (namespace == "/,") {
            // omit default namespace
            namespace = "";
        }

        var ackId = "";
        if (this.ackNumber != null) {
            ackId = Std.string(this.ackNumber);
        }

        var encodedJson = "";
        if (this.json != null) {
            encodedJson = haxe.Json.stringify(this.json);
        }
        return '$typeInt$nAttachments$namespace$ackId$encodedJson';
    }

    // TODO: decode binary payloads
    public static function decode(encoded: String) {

        inline function isDigit(s: String) {
            return s >= "0" && s <= "9";
        }

        var typeInt: PacketType = Std.parseInt(encoded.charAt(0));
        var remaining = encoded.substr(1);

        var nAttachments: Null<Int> = 0;
        var dash = remaining.indexOf("-");
        if (isDigit(remaining.charAt(0)) && dash != -1) {
            nAttachments = Std.parseInt(remaining.substr(0, dash));
            if (nAttachments == null) {
                // if it's not a number, there's no binary count
                nAttachments = 0;
            } else {
                remaining = remaining.substr(dash+1);
                // TODO: binary limit, 10?
            }
        }

        var namespace = "/";
        var isNamespace = remaining.charAt(0) == "/";
        if (isNamespace) {
            var namespaceEnd = remaining.indexOf(",");
            if (namespaceEnd == -1) {
                // TODO: python implementation just uses the rest of the packet
                // as namespace, but is that in the spec?
                throw "invalid packet";
            }
            namespace = remaining.substr(0, namespaceEnd);
            remaining = remaining.substr(namespaceEnd + 1);
        }

        var i = 0;
        var ackString = "";
        while (i < remaining.length && isDigit(remaining.charAt(i))) {
            ackString += remaining.charAt(i);
            i++;
        }
        var ackNumber: Null<Int> = null;
        if (ackString != "") {
            ackNumber = Std.parseInt(ackString);
        }

        var json: Null<Dynamic> = null;
        if (remaining.length > 0) {
            json = haxe.Json.parse(remaining);
        }

        return new Packet(
            typeInt,
            json,
            namespace,
            ackNumber,
            nAttachments,
        );
    }

}

package socketio.test;

import socketio.Packet;


class Main {

    public static function main() {
        encodeDecodeTest();
    }

    public static function encodeDecodeTest() {

        function check(name: String, p: Packet, expected: String) {
            var result = p.encode();
            if (result != expected) {
                trace('-----');
                trace('[\033[31mfailure\033[0;37m] (encode) $name');
                trace('  expected: $expected');
                trace('       got: $result');
                trace('-----');
            } else {
                trace('[\033[32msuccess\033[0;37m] (encode) $name ');
            }

            result = Packet.decode(expected).encode();
            if (result != expected) {
                trace('-----');
                trace('[\033[31mfailure\033[0;37m] (decode) $name');
                trace('  expected: $expected');
                trace('       got: $result');
                trace('-----');
            } else {
                trace('[\033[32msuccess\033[0;37m] (decode) $name ');
            }
        }

        // examples from socketio docs
        check(
            "empty connect packet",
            new Packet(CONNECT, null, "/"),
            "0"
        );
        check(
            "connect with namespace",
            new Packet(CONNECT, {sid: "oSO0OpakMV_3jnilAAAA"}, "/admin"),
            "0/admin,{\"sid\":\"oSO0OpakMV_3jnilAAAA\"}"
        );
        check(
            "connect error",
            new Packet(CONNECT_ERROR, {message: "Not Authorized"}, "/"),
            "4{\"message\":\"Not Authorized\"}"
        );
        check(
            "event",
            new Packet(EVENT, ["foo"]),
            "2[\"foo\"]"
        );
        check(
            "event and namespace",
            new Packet(EVENT, ["bar"], "/admin"),
            "2/admin,[\"bar\"]",
        );
        // TODO: binary attachments
        check(
            "with ack id",
            new Packet(EVENT, ["foo"], "/", 12),
            "212[\"foo\"]"
        );
        check(
            "ack with namespace",
            new Packet(ACK, ["bar"], "/admin", 13),
            "3/admin,13[\"bar\"]"
        );
        check(
            "disconnect",
            new Packet(DISCONNECT),
            "1"
        );
        check(
            "disconnect with namespace",
            new Packet(DISCONNECT, null, "/admin"),
            "1/admin,"
        );
    }

}

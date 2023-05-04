package socketio.test;

import socketio.Packet;
import socketio.Server;

import socketio.Namespace;
import socketio.BroadcastOperator;


class Main {

    public static function main() {
        // encodeDecodeTest();
        serverTest();
    }

    public static function serverTest() {
        var sio = new Server();

        // special events fired by the server
        sio.on("connect", function (sid, data) {
            trace('$sid connected');
            // throw new socketio.DenyConnection("");
        });

        sio.on("create-room", function(sid, data) {
            trace('created room: ${data.room}');
        });

        sio.on("join-room", function(sid, data) {
            trace('$sid joined room: ${data.room}');
        });

        // TODO: disconnect, create-room, leave-room, delete-room

        // events
        sio.on("test_event", function (sid, data) {
            trace('Test Event From $sid');
            sio.emit("server_event", {data: "foobar"});
            sio.of("/").emit("of_event", {data: "asdf"});
        });
        sio.onCatchAll(function (event, sid, data) {
            trace('$event: $sid');
        });
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

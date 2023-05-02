package socketio.test;

import socketio.Packet;
import socketio.Server;

import socketio.Socket;
import socketio.Namespace;
import socketio.BroadcastOperator;


class Main {

    public static function main() {
        // encodeDecodeTest();
        broadcastOperatorTest();
    }

    public static function broadcastOperatorTest() {
        var namespace = new Namespace("/");

        var socket = new Socket("asdf", namespace.adapter);
        namespace.addSocket(socket);
        socket.join("one");

        namespace.to(["one", "two", "three"]).except(["two"]).emit("my_event", {});
    }

//    public static function serverTest() {
//        var sio = new Server();
//
//        // events
//        sio.on("my_event", function (sid, data) {
//            trace('my_event: $sid');
//        });
//        sio.on("*", function (event, sid, data) {
//            trace('$event: $sid');
//        });
//
//        // connect, disconnect are automatic
//        // return False or throw error in conenct do reject
//
//        // emi
//        sio.emit("my_event", {data: "foobar"});
//        sio.emit("my_event", {data: "foobar"}, "some_room");
//
//        // namespaces
//        sio.of("/chat").on("my_event", function (sid, data)
//
//        // sio.registerNamespace(new CustomNamespace("/test"));
//    }

/* TODO
class CustomNamespace extends socketio.Namespace {

    public function on_connect(sid) {
    }

    public function on_disconnect(sid) {
    }

    // TODO: macro? how to register?
    public function on_my_event(sid, data) {
        self.emite("my_response", data);
    }

}
*/

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

# haxe-socketio

A (work in progress) Haxe implementation of the socket.io protocol.

## Install
```
haxelib git haxe-socketio https://github.com/snwhd/haxe-socketio.git
# TODO: haxelib install haxe-socketio
```

## Example Server

```haxe

class Main {

    public static function main() {

        var sio = new Server();

        // handle a specific event
        sio.on("test_event", function (sid, data) {
            trace('Test Event From $sid');
        });

        // catch all for events without a handler
        sio.onCatchAll(function (event, sid, data) {
            trace('$event: $sid');
        });

    }

}
```

## Example Client
TODO

#!/usr/bin/env python3
import socketio


sio = socketio.Client()


@sio.event
def test_event(data):
    print(f"test: {data}")


@sio.on("*")
def catch_all(event, data):
    print(f"{event} - {data}");


@sio.event
def connect():
    print(f"connected: {sio.sid}")
    sio.emit("test_event", {"asdf": "poo"})
    sio.emit("anotherthing", {"asdf": "poo"})


@sio.event
def disconnect():
    print("disconnected")


sio.connect("ws://localhost:8080")

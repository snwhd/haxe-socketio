#!/usr/bin/env python3
import socketio


sio = socketio.Client()

@sio.event
def connect():
    print(f"connected: {sio.sid}")


@sio.event
def disconnect():
    print("disconnected")


sio.connect("ws://localhost:8080")

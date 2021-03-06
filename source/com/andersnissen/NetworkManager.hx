package com.andersnissen;

#if USE_SOCKETS
import sockjs.SockJS;
#end

class NetworkManager
{
    #if USE_SOCKETS
    var socket :SockJS;
    #end

    public function new() :Void
    {

    }

    public function connect() :Void
    {
        #if USE_SOCKETS
        // Create socket (automatically reconnect when connection is lost).
        socket = new SockJS("http://192.168.1.10:9999/echo", { reconnect: true });

        // Listen open event
        socket.onOpen(function() {
            trace("Socket did open");
            // socket.send("Hello!");
        });

        // Listen message event
        socket.onMessage(function(message) {
            trace("Socket did receive message: " + message);
        });

        // Listen error event
        socket.onError(function(error) {
            trace("Socket failed with error: " + error);
        });

        // Listen close event
        socket.onClose(function() {
            trace("Socket did close");
        });

        trace("Socket connecting...");

        // Connect socket
        socket.connect();
        #end
    }

    public function send(data :Dynamic) :Void
    {
        #if USE_SOCKETS
        if (!socket.isConnected()) {
            trace("Cannot send; socket is not connected");

            return;
        }

        socket.send(haxe.Json.stringify(data));
        #end

        // posting to https://data.sparkfun.com/streams/1nn3V2nQvEtrMR1V16KK
        var request = new haxe.Http("http://data.sparkfun.com/input/1nn3V2nQvEtrMR1V16KK?private_key=0mmWG4mVKMU6Z2zMz0XX");
        request.setParameter("games", haxe.Json.stringify(data.games));
        request.request(true);
    }
}

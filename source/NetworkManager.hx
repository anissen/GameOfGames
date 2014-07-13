
package ;

import sockjs.SockJS;

class NetworkManager 
{
    var socket :SockJS;

    public function new() :Void
    {

    }

    public function connect() :Void
    {
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
    }

    public function send(data :Dynamic) :Void
    {
        if (!socket.isConnected()) {
            trace("Cannot send; socket is not connected");

            return;
        }

        socket.send(haxe.Json.stringify(data));
    }
}

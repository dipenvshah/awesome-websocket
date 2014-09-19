This socket is powerful. So powerful that it will try forever to reconnect to
all the specified servers until you call close. It will not give up. It will not
relent.

OK -- so this socket, on send, will roll through all connected sockets, and the
first one that does a successful transport wins. All connected sockets are
possible sources for incoming messages.

Oh -- and this is a *client side* WebSocket, and is set up to work
with [Browserify](http://browserify.org/). Client side matters since it initiates
the WebSocket connection, so is the only side in a place to reconnect.

If you explicitly call `close()`, then this socket will really close, otherwise
it will work to automatically reconnect `onerror` and `onclose` from the
underlying WebSocket.

    ReconnectingWebSocket = require('./reconnecting-websocket.litcoffee')
    WebSocket = window?.WebSocket || require('ws')
    background = window?.requestAnimationFrame or setTimeout
    MAX_TRIES = 2

You feed the AwesomeWebSocket two things; url(s) and message try counts.  The **urls** argument can either be a string with
one web socket endpoint or it can be an array of strings representing multiple.

The second argument, **tryMax**, is the maximum amount of times **PER SOCKET** that message will be tried.  If the
**tryMax** is set to 2 and you provide 3 URLs, the message will be tried 6 times before it's popped from the queue.

    class AwesomeWebSocket
      constructor: (@urls) ->
        openAtAll = false
        @lastSocket = undefined
        @sockets = []
        @messageQueue = []
        if typeof(@urls) is "string"
          @urls = [@urls]

All the urls are reconnecting sockets, these will connect themselves.

        for url in @urls
          socket = new ReconnectingWebSocket(url)
          @sockets.push socket

Event relay. Maybe I should call it *baton* not *evt*. Anyhow, the
`ReconnectingWebSocket` handles the underlying `WebSocket` so we don't need
to hookup each time we reopen.

          socket.onmessage = (evt) =>
            @onmessage evt
          socket.onerror = (err) =>
            @onerror err
          socket.onopen = (evt) =>
            if not openAtAll
              openAtAll = true
              @onopen evt

        @forceclose = false

Here is the magic, in the background we try very hard to send message
out to the connected servers, and only take a message off the queue if
at least the client side of the socket thinks the deed is done.

        sendloop = =>

Do this first, on purpose. Our buddy `send` below will throw an
un-catch-able exception, so there wouldn't be that much opportunity
toward the end of this function.

          background sendloop
          if @messageQueue.length

This is a very simple form of sticky preference for the last socket that worked.
And if not treat the array of sockets as a ring buffer.

            if @lastSocket
              trySocket = @lastSocket
              @lastSocket = null
            else
              trySocket = @sockets.pop()
              @sockets.unshift trySocket

            item = @messageQueue[@messageQueue.length-1]

            if trySocket.readyState is WebSocket.OPEN
              trySocket.send(item.data)
              @lastSocket = trySocket
              @messageQueue.pop()

Start pumping messages.

        background sendloop

Sending just queues up a message to go out to the server.

      send: (data) ->
        @messageQueue.unshift data: data, tryCount: 0

Allow for specifiecation of a keep alive, which is just passed on to the
underlying reconnecting sockets.

      keepAlive: (timeoutMs, message) ->
        for socket in @sockets
          socket.keepAlive(timeoutMs, message)

Close all the sockets.

      close: ->
        for socket in @sockets
          socket.close()
        @onclose()



Empty shims for the event handlers. These are just here for discovery via
the debugger.

      onopen: (event) ->
      onclose: (event) ->
      onmessage: (event) ->
      onerror: (event) ->

Publish this object for browserify.

    module.exports = AwesomeWebSocket

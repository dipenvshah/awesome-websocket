This socket is powerful. So powerful that it will try forever to reconnect to
all the specified servers until you call close. It will not give up. It will not
relent.

OK -- so this socket, on send, will roll through all connected sockets, and the
first one that does a successful transport wins. All connected sockets are
possible sources for incoming messages.

If you explicitly call `close()`, then this socket will really close, otherwise
it will work to automatically reconnect `onerror` and `onclose` from the
underlying WebSocket.

#Events
##onserver(event)
This is fired when the active server changes, this will be after a `send` as
that is the only time the socket has activity to 'know' it switched servers.

    ReconnectingWebSocket = require('./reconnecting-websocket.js').ReconnectingWebSocket
    WebSocket = WebSocket or require('ws')

    class HuntingWebSocket
      constructor: (@urls) ->
        openAtAll = false
        @currSocket = undefined
        @huntIndex = 0
        @pendingMessages = []
        @sockets = []
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
              @currSocket = socket
              @onopen evt
            @onconnectionopen socket.underlyingWs.url
            @processPendingMessages()
          socket.onreconnect = (evt) =>
            @onreconnect evt
            @processPendingMessages()
            

If there was a problem sending this message, let's try another socket

          socket.ondatanotsent = (evt) =>
            @pendingMessages.push evt.data
            if ++@huntIndex >= @sockets.length
              @huntIndex = 0
            @currSocket = @sockets[@huntIndex]
            @ondatanotsent evt
      

      send: (data) ->
        if @currSocket
          @currSocket.send data
        else
          @pendingMessages.push data

      processPendingMessages: () ->
        while message = @pendingMessages.shift()
          @send(message)

Close all the sockets.

      close: ->
        for socket in @sockets
          socket.close()
        @onclose()

Empty shims for the event handlers. These are just here for discovery via
the debugger.

      onopen: (event) ->
      onreconnect: (event) ->
      onclose: (event) ->
      onmessage: (event) ->
      onerror: (event) ->
      onconnectionopen: (event) ->
      ondatanotsent: (event) ->

Publish this object for browserify.

    module.exports = HuntingWebSocket

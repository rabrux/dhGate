###
# packages
rsa = require 'node-rsa'

# env vars
debug = process.env.DEBUG || true

reserved = [ 'forward', 'register' ]

module.exports = ( io ) ->

( socket, next ) ->

  socket.on 'register', ( agent ) ->
    # bad request
    return socket.response 400 if not agent?.name or not agent?.publicKey

    # reserved task name
    return socket.response 405 if agent.name in reserved

    # save agent schema
    socket._agent = agent

    # join to room
    socket.join agent.name
    #console.log ' = rooms', io.sockets.adapter.rooms

    # encrypt message
    key = new rsa socket._agent.publicKey, 'public'
    cryptedMessage = key.encrypt 'hello world', 'base64'

    return socket.response null, cryptedMessage

  socket.on 'genesis', ( data ) ->
    console.log 'genesis', data

  socket.on 'disconnect', ->
    console.log '<- client disconnected', socket.id

  # hooks
  # params
  socket.use ( packet, next ) ->

    # event prefix
    socket.eventName = packet[0]

    # response function
    socket.response = ( err, data ) ->
      return socket.emit socket.eventName + ':error', err if err
      return socket.emit socket.eventName + ':success', data

    next()

  # forward
  socket.use ( packet, next ) ->
    return next() if socket.eventName in reserved
    room = io.sockets.adapter.rooms[ socket.eventName ]
    if room
      console.log '------------- BEGIN -----------------'
      genesis =
        client  : socket.id
        _params : packet[1]

      pack =
        _params  : packet[1]
        _genesis : if packet[1]?._genesis then packet[1]._genesis else genesis
      console.log socket.eventName
      console.log JSON.stringify pack, null, 2
      console.log '-------------- END ------------------'
      io.to( socket.eventName ).emit 'task', pack
    next()

  # log
  socket.use ( packet, next ) ->
    console.log '->', socket.id, socket.eventName
    next()

  # debug mode
  if debug
    socket.use ( packet, next ) ->
      console.log packet
      next()

  next()
###


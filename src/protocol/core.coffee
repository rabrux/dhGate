# packages
rsa = require 'node-rsa'

module.exports = ( socket, next ) ->

  socket.on 'register', ( agent ) ->
    # bad request
    return socket.response 400 if not agent?.name or not agent?.publicKey

    # save agent schema
    socket._agent = agent

    # join to room
    socket.join agent.name

    # encrypt message
    key = new rsa socket._agent.publicKey, 'public'
    cryptedMessage = key.encrypt 'hello world', 'base64'

    return socket.response null, cryptedMessage

  socket.on 'disconnect', ->
    console.log 'client disconnected', socket.id

  ###
  # hooks
  ###
  socket.use ( packet, next ) ->

    # event prefix
    socket.eventName = packet[0]

    # response function
    socket.response = ( err, data ) ->
      return socket.emit socket.eventName + ':error', err if err
      return socket.emit socket.eventName + ':success', data

    next()

  next()



module.exports = ( io ) ->

  # on connection handler
  connection = require( './_connection' ) io
  io.on 'connection', connection

  ( socket, next ) ->

    # register
    register = require( './_register' ) io
    socket.on 'register', register

    next()


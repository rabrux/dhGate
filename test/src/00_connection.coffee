io     = require 'socket.io-client'
should = require( 'chai' ).should()
rs     = require 'randomstring'

describe 'connection test -', ->

  @timeout 10000

  it 'connection success', ( done ) ->
    socket = io 'http://localhost:1337',
      forceNew : true

    socket.on 'connect', ->
      socket.connected.should.be.equal true
      socket.disconnect()
      done()


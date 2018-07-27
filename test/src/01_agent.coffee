io     = require 'socket.io-client'
should = require( 'chai' ).should()
rsa    = require 'node-rsa'
rs     = require 'randomstring'

describe 'agent -', ->

  @timeout 10000

  socket = undefined
  key    = undefined

  beforeEach ( done ) ->
    socket = io 'http://localhost:1337',
      forceNew : true

    socket.on 'connect', ->
      done()

    socket.on 'disconnect', ->

    return

  afterEach ( done ) ->
    if socket.connected
      socket.disconnect()
    done()

  it 'create ssh keys', ( done ) ->
    key = new rsa b: 512
    done()

  it 'bad register params', ( done ) ->
    socket.emit 'register'
    socket.on 'register:error', ( err ) ->
      err.should.be.equal 400
      done()

  it 'register success', ( done ) ->
    socket.emit 'register',
      name      : 'auth:login'
      publicKey : key.exportKey 'public'
      params :
        username : 'String'
        password : 'String'
    socket.on 'register:success', ( data ) ->
      decryptedMessage = key.decrypt data, 'utf8'
      decryptedMessage.should.be.equal 'hello world'
      done()

  it 'register faild by reserved task name', ( done ) ->
    socket.emit 'register',
      name      : 'forward'
      publicKey : key.exportKey 'public'
    socket.on 'register:error', ( err ) ->
      err.should.be.equal 405
      done()


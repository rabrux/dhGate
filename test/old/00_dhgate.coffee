{ dhGate } = require '../../dist'
client     = require 'socket.io-client'
should     = require( 'chai' ).should()

# environment variables
PORT = process.env.PORT || 1337

# client vars
uri  = "http://localhost:#{ PORT }"
opts = forceNew : true
describe 'gate -', ->

  @timeout 1000

  gate = undefined

  beforeEach ( done ) ->
    gate = new dhGate PORT
    done()

  afterEach ( done ) ->
    gate.close()
    done()

  it 'gate instanceof dhGate', ( done ) ->
    ( gate instanceof dhGate ).should.be.equal true
    done()

  it 'gate client connection', ( done ) ->
    socket = client uri, opts
    socket.on 'connect', ->
      done()


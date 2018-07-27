{ dhGate } = require '../../dist'
client     = require 'socket.io-client'
should     = require( 'chai' ).should()

# environment variables
PORT = process.env.PORT || 1337

# client vars
uri  = "http://localhost:#{ PORT }"
opts = forceNew : true
describe 'task agent -', ->

  @timeout 1000

  gate = undefined

  beforeEach ( done ) ->
    gate = new dhGate PORT
    done()

  afterEach ( done ) ->
    gate.close()
    done()

  it 'missing params on create agent'
  it 'fail registration by reserved name'
  it 'success registration'


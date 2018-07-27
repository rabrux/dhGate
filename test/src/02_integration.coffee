io     = require 'socket.io-client'
should = require( 'chai' ).should()
rsa    = require 'node-rsa'
rs     = require 'randomstring'

# socket params
uri     = 'http://localhost:1337'
options = forceNew : true

describe 'integration -', ->

  @timeout 5000

  socket = undefined
  key    = undefined

  describe 'auth workflow simulation -', ->

    mongoFindOne = undefined
    authLogin    = undefined
    authToken    = undefined
    userList     = undefined
    client       = undefined

    it 'create agent mongo:findOne', ( done ) ->
      # create
      mongoFindOne = io uri, options
      # register on connect
      mongoFindOne.on 'connect', ->
        mongoFindOne.key = new rsa b: 512
        mongoFindOne.emit 'register',
          name      : 'mongo:findOne'
          publicKey : mongoFindOne.key.exportKey 'public'
          params :
            collection : 'String'
            query : 'Object'
      # register success
      mongoFindOne.on 'register:success', ( data ) ->
        decryptedMessage = mongoFindOne.key.decrypt data, 'utf8'
        decryptedMessage.should.be.equal 'hello world'
        done()
      # task execution
      mongoFindOne.on 'task', ( data ) ->
        console.log 'mongoFindOne', data
        # history
        history = data._history || []
        history.push data
        # send error to genesis
        mongoFindOne.emit 'genesis',
          error : 404
          _history : history

    it 'create agent auth:token', ( done ) ->
      # create
      authToken = io uri, options
      # register on connect
      authToken.on 'connect', ->
        authToken.key = new rsa b: 512
        authToken.emit 'register',
          name      : 'auth:token'
          publicKey : authToken.key.exportKey 'public'
          params :
            user : 'String'
      # register success
      authToken.on 'register:success', ( data ) ->
        decryptedMessage = authToken.key.decrypt data, 'utf8'
        decryptedMessage.should.be.equal 'hello world'
        done()
      # task execution
      authToken.on 'task', ( data ) ->
        console.log data

    it 'create agent auth:login', ( done ) ->
      # create
      authLogin = io uri, options
      # register on connect
      authLogin.on 'connect', ->
        authLogin.key = new rsa b: 512
        authLogin.emit 'register',
          name      : 'auth:login'
          publicKey : authLogin.key.exportKey 'public'
          params :
            username : 'String'
            password : 'String'
      # register success
      authLogin.on 'register:success', ( data ) ->
        decryptedMessage = authLogin.key.decrypt data, 'utf8'
        decryptedMessage.should.be.equal 'hello world'
        done()
      # auth login task exec
      authLogin.on 'task', ( data ) ->
        console.log data
        ###
        # history
        history = data?._history || []
        history.push data
        # response
        authLogin.emit 'mongo:findOne',
          collection : 'User'
          query :
            username : data._params.username
          _forward : 'auth:token'
          _history : history
        ###

    it 'create agent user:list', ( done ) ->
      # create
      userList = io uri, options
      userList.task = ( params ) ->
      # register on connect
      userList.on 'connect', ->
        userList.key = new rsa b: 512
        userList.emit 'register',
          name      : 'user:list'
          publicKey : userList.key.exportKey 'public'

        # hook
        _on = userList.onevent
        userList.onevent = ( packet ) ->
          console.log 'packet', packet
          args = packet.data || []
          eventName = packet.data[0]
          return _on.call userList, packet if eventName isnt 'task'

          userList.task

      # register success
      userList.on 'register:success', ( data ) ->
        decryptedMessage = userList.key.decrypt data, 'utf8'
        decryptedMessage.should.be.equal 'hello world'
        done()
      ###
      # auth login task exec
      userList.on 'task', ( data ) ->
        console.log 'task', data
        console.log @
      ###

    it 'create client', ( done ) ->
      # create
      client = io uri, options
      client.should.be.an 'object'
      done()

    it 'send user:list task to gate', ( done ) ->
      # emit task
      client.emit 'user:list', 1234
      client.on 'user:list:success', ( data ) ->
        done()

    ###
    it 'send auth:login task to gate', ( done ) ->
      # emit task
      client.emit 'auth:login',
        username : 'root'
        password : 'toor'
      client.on 'auth:login:success', ( data ) ->
        should.exist data.token
        done()
    ###

    it 'close connections', ( done ) ->
      client.disconnect()
      mongoFindOne.disconnect()
      authToken.disconnect()
      authLogin.disconnect()
      done()


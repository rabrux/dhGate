path   = require 'path'
moment = require 'moment'
socket = require 'socket.io-client'

FSHelper    = require '../lib/FSHelper'
Transaction = require '../core/Transaction'

class TaskClient

  constructor : ( app ) ->
    if not app?.uri or not app?.modules or not app?.task
      throw Error 'missing params'

    @_uri     = app.uri
    @_modules = app.modules
    @_task    = app.task
    @_timeout = app.timeout || 10

    @validate()
    @run()

  validate : ->
    fsh = new FSHelper @modulesPath()
    if not fsh.isDirectory()
      throw Error 'modules path is not a directory'

    taskPath = path.join process.cwd(), @modulesPath(), @moduleFile()
    try
      @_process = require taskPath
    catch e
      throw Error "task #{ taskPath } is not available"

  run : ->
    @_socket = socket @getUri()

    it = @

    @_socket.on 'connect', ->
      @emit 'register', it.getTask()
      it.extendTimeout()
      it.tick()

    @_socket.on 'task', ( transaction ) ->
      it.extendTimeout()
      transaction = new Transaction transaction
      it._process it.socket(), transaction

  extendTimeout : ->
    @timeout = moment().add @_timeout, 'minutes'

  tick : ->
    it = @
    setInterval( ->
      diff = moment().diff it.timeout, 'minutes'
      if diff >= 0
        it.socket().emit 'shutdown', it.getTask()
        return process.exit( 1 )
      it.tick()
    , 60000 ).unref()

  # getters and setters
  getUri      : -> @_uri
  getTask     : -> @_task
  modulesPath : -> @_modules
  moduleFile  : -> @_task.split( ':' ).join path.sep

  socket : -> @_socket

module.exports = TaskClient

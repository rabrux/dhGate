io    = require 'socket.io'
execa = require 'execa'

# core
Transaction = require './core/Transaction'
Task        = require './core/Task'
TaskClient  = require './core/TaskClient'

# libs
FSHelper   = require './lib/FSHelper'
Collection = require './lib/Collection'

class dhGate extends io

  constructor : ( srv, opts ) ->

    if not srv
      throw Error 'missing params ( srv )'

    super srv, opts
    # save this to it
    it = @

    # init room and transaction collections
    @_rooms        = new Collection 'string'
    @_transactions = new Collection Transaction

    @on 'connect', ( socket ) ->
      socket.on 'register', ( room ) ->
        socket.join room
        transactions = it._transactions.findByKey '_task.to', room
        for transaction in transactions
          it.to( room ).emit 'task', transaction
        # remove sent transactions
        it._transactions.remove transactions
        # remove room
        it._rooms.remove it._rooms.find room

      socket.on 'task', ( task ) ->
        transaction = new Transaction new Task task, socket.id
        it.process transaction

      socket.on 'forward', ( transaction ) ->
        transaction = new Transaction transaction
        it.process transaction

      socket.on 'shutdown', ->

  getRooms   : -> @sockets.adapter.rooms
  getClients : -> @sockets.clients().connected

  isClient : ( id ) -> @getClients()[ id ]

  register : ( transaction ) ->
    isStacked = @_transactions.findByKey( '_id', transaction.getId() )
    if isStacked.length is 0
      @_transactions.register transaction

  process : ( transaction ) ->
    if @isClient( transaction.getTo() )
      params = transaction.getTask().params
      to     = transaction.getTo()
      event  = transaction.getEvent()
      params = params.doc if params.doc
      return @to( to ).emit event, params

    room = transaction.getTo()
    if not @getRooms()[ room ]
      isRoomStacked = @_rooms.find room
      # prevent load many instances
      if isRoomStacked.length is 0
        @_rooms.register room
        @register transaction
        # exec agent
        execa 'pm2', [ 'start', 'ecosystem.json', '--only', transaction.getTo() ]
    else
      @to( transaction.getTo() ).emit 'task', transaction

module.exports =
  dhGate      : dhGate
  Task        : Task
  TaskClient  : TaskClient
  Transaction : Transaction
  FSHelper    : FSHelper
  Collection  : Collection

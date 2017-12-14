io    = require 'socket.io'
execa = require 'execa'
path  = require 'path'

Transaction = require './core/Transaction'
Task        = require './core/Task'
FSHelper    = require './lib/FSHelper'

class dhGate extends io

  constructor : ( srv, opts ) ->
    super srv, opts
    # save this to it
    it = @

    # init
    @checkRootPath opts?.root
    @initTransactions()
    @initRooms()

    # base protocol
    @on 'connect', ( socket ) ->

      socket.on 'register', ( room ) ->
        socket.join room
        console.log 'room created for task', room
        it._rooms.splice it._rooms.indexOf( room ), 1
        transactions = it.findTransactionByType room
        for t in transactions
          it.to( room ).emit t.getEvent(), t
        it.removeTransactions transactions

      # task trigger listener for clients
      socket.on 'task', ( task ) ->
        trans = new Transaction new Task task, socket.id

        it.processTransaction trans

      socket.on 'forward', ( trans ) ->
        trans = new Transaction trans

        it.processTransaction trans

  # transaction functions
  getTransactions : -> @_transactions

  processTransaction : ( trans ) ->
    # load task
    if not @findRoomByType( trans.getTo() )
      # prevent load many
      if @_rooms.indexOf( trans.getTo() ) is -1
        # save room to prevent many
        @_rooms.push trans.getTo()
        @registerTransaction trans
        execa 'pm2', [ 'start', 'ecosystem.json', '--only', trans.getTo() ]
    # emit task to be process
    else
      @to( trans.getTo() ).emit trans.getEvent(), trans

  registerTransaction : ( trans ) ->
    console.log 'register transaction', trans.getId(), trans.getTo()
    isStacked = @getTransactions().filter ( el ) -> el.getId() is trans.getId()
    if isStacked.length is 0
      @_transactions.push trans

  findTransactionByType : ( type ) ->
    @_transactions.filter ( el ) -> el.getTo() is type

  removeTransactions : ( trans ) ->
    if trans instanceof Array
      for t in trans
        @removeTransactions t
    if trans instanceof Transaction
      index = @_transactions.indexOf trans
      @_transactions.splice index, 1

  # room functions
  getRooms : -> @sockets.adapter.rooms

  findRoomByType : ( type ) ->
    @getRooms()[ type ]


  # init functions for transactions and rooms
  initTransactions : -> @_transactions = []
  initRooms        : -> @_rooms = []

  # check if services path is a directory
  checkRootPath : ( _path ) ->
    if not _path
      throw 'you must to set <services> directory'

    fsh = new FSHelper _path
    if not fsh.isDirectory()
      throw '<services> path is not a directory'

    @_root = _path

  getRoot : -> @_root

module.exports =
  dhGate      : dhGate
  Task        : Task
  Transaction : Transaction

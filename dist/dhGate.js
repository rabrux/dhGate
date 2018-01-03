(function() {
  var Collection, FSHelper, Task, TaskClient, Transaction, dhGate, execa, io,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  io = require('socket.io');

  execa = require('execa');

  Transaction = require('./core/Transaction');

  Task = require('./core/Task');

  TaskClient = require('./core/TaskClient');

  FSHelper = require('./lib/FSHelper');

  Collection = require('./lib/Collection');

  dhGate = (function(superClass) {
    extend(dhGate, superClass);

    function dhGate(srv, opts) {
      var it;
      if (!srv) {
        throw Error('missing params ( srv )');
      }
      dhGate.__super__.constructor.call(this, srv, opts);
      it = this;
      this._rooms = new Collection('string');
      this._transactions = new Collection(Transaction);
      this.on('connect', function(socket) {
        socket.on('register', function(room) {
          var i, len, transaction, transactions;
          socket.join(room);
          transactions = it._transactions.findByKey('_task.to', room);
          for (i = 0, len = transactions.length; i < len; i++) {
            transaction = transactions[i];
            it.to(room).emit('task', transaction);
          }
          it._transactions.remove(transactions);
          return it._rooms.remove(it._rooms.find(room));
        });
        socket.on('task', function(task) {
          var transaction;
          transaction = new Transaction(new Task(task, socket.id));
          return it.process(transaction);
        });
        socket.on('forward', function(transaction) {
          transaction = new Transaction(transaction);
          return it.process(transaction);
        });
        return socket.on('shutdown', function() {});
      });
    }

    dhGate.prototype.getRooms = function() {
      return this.sockets.adapter.rooms;
    };

    dhGate.prototype.getClients = function() {
      return this.sockets.clients().connected;
    };

    dhGate.prototype.isClient = function(id) {
      return this.getClients()[id];
    };

    dhGate.prototype.register = function(transaction) {
      var isStacked;
      isStacked = this._transactions.findByKey('_id', transaction.getId());
      if (isStacked.length === 0) {
        return this._transactions.register(transaction);
      }
    };

    dhGate.prototype.process = function(transaction) {
      var event, isRoomStacked, params, room, to;
      if (this.isClient(transaction.getTo())) {
        params = transaction.getTask().params;
        to = transaction.getTo();
        event = transaction.getEvent();
        if (params.doc) {
          params = params.doc;
        }
        return this.to(to).emit(event, params);
      }
      room = transaction.getTo();
      if (!this.getRooms()[room]) {
        isRoomStacked = this._rooms.find(room);
        if (isRoomStacked.length === 0) {
          this._rooms.register(room);
          this.register(transaction);
          return execa('pm2', ['start', 'ecosystem.json', '--only', transaction.getTo()]);
        }
      } else {
        return this.to(transaction.getTo()).emit('task', transaction);
      }
    };

    return dhGate;

  })(io);

  module.exports = {
    dhGate: dhGate,
    Task: Task,
    TaskClient: TaskClient,
    Transaction: Transaction,
    FSHelper: FSHelper,
    Collection: Collection
  };

}).call(this);

(function() {
  var FSHelper, Task, Transaction, dhGate, execa, io,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  io = require('socket.io');

  execa = require('execa');

  Transaction = require('./core/Transaction');

  Task = require('./core/Task');

  FSHelper = require('./lib/FSHelper');

  dhGate = (function(superClass) {
    extend(dhGate, superClass);

    function dhGate(srv, opts) {
      var it;
      dhGate.__super__.constructor.call(this, srv, opts);
      it = this;
      this.checkRootPath(opts != null ? opts.root : void 0);
      this.initTransactions();
      this.initRooms();
      this.on('connect', function(socket) {
        socket.on('register', function(room) {
          var i, len, t, transactions;
          socket.join(room);
          console.log('room created for task', room);
          it._rooms.splice(it._rooms.indexOf(room), 1);
          transactions = it.findTransactionByType(room);
          for (i = 0, len = transactions.length; i < len; i++) {
            t = transactions[i];
            it.to(room).emit(t.getEvent(), t);
          }
          return it.removeTransactions(transactions);
        });
        socket.on('task', function(task) {
          var trans;
          trans = new Transaction(new Task(task, socket.id));
          return it.processTransaction(trans);
        });
        return socket.on('forward', function(trans) {
          trans = new Transaction(trans);
          return it.processTransaction(trans);
        });
      });
    }

    dhGate.prototype.checkRootPath = function(_path) {
      var fsh;
      if (!_path) {
        throw 'you must to set <services> directory';
      }
      fsh = new FSHelper(_path);
      if (!fsh.isDirectory()) {
        throw '<services> path is not a directory';
      }
      return this._root = _path;
    };

    dhGate.prototype.getTransactions = function() {
      return this._transactions;
    };

    dhGate.prototype.findTransactionByType = function(type) {
      return this._transctions.filter(function(el) {
        return el.getTo() === type;
      });
    };

    dhGate.prototype.processTransaction = function(trans) {
      if (!this.findRoomByType(trans.getTo())) {
        if (this._rooms.indexOf(trans.getTo()) === -1) {
          this._rooms.push(trans.getTo());
          this.registerTransaction(trans);
          return execa('pm2', ['start', 'ecosystem.json', '--only', trans.getTo()]);
        }
      } else {
        return this.to(trans.getTo()).emit(trans.getEvent(), trans);
      }
    };

    dhGate.prototype.registerTransaction = function(trans) {
      var isStacked;
      console.log('register transaction', trans.getId(), trans.getTo());
      isStacked = this.getTransactions().filter(function(el) {
        return el.getId() === trans.getId();
      });
      if (isStacked.length === 0) {
        return this._transactions.push(trans);
      }
    };

    dhGate.prototype.removeTransactions = function(trans) {
      var i, index, len, t;
      if (trans instanceof Array) {
        for (i = 0, len = trans.length; i < len; i++) {
          t = trans[i];
          this.removeTransactions(t);
        }
      }
      if (trans instanceof Transaction) {
        index = this._transactions.indexOf(trans);
        return this._transactions.splice(index, 1);
      }
    };

    dhGate.prototype.findRoomByType = function(type) {
      return this.getRooms()[type];
    };

    dhGate.prototype.getRooms = function() {
      return this.sockets.adapter.rooms;
    };

    dhGate.prototype.initRooms = function() {
      return this._rooms = [];
    };

    dhGate.prototype.initTransactions = function() {
      return this._transactions = [];
    };

    dhGate.prototype.getRoot = function() {
      return this._root;
    };

    return dhGate;

  })(io);

  module.exports = {
    dhGate: dhGate,
    Task: Task,
    Transaction: Transaction
  };

}).call(this);

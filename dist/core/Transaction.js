(function() {
  var Task, Transaction, rs;

  rs = require('randomstring');

  Task = require('./Task');

  Transaction = (function() {
    function Transaction(transaction) {
      if (transaction instanceof Task) {
        this.setId();
        this.setTask(transaction);
        this.setHistory();
      } else {
        this.setId(transaction._id);
        this.setTask(new Task(transaction._task));
        this.setHistory();
        this.loadTasks(transaction._history);
      }
    }

    Transaction.prototype.pushTask = function(task) {
      this._history.push(this.getTask());
      if (!task._onSuccess) {
        task._onSuccess = this.getTask().getOnSuccess();
      }
      if (!task._onError) {
        task._onError = this.getTask().getOnError();
      }
      return this.setTask(task);
    };

    Transaction.prototype.generateId = function() {
      return rs.generate({
        length: 15
      });
    };

    Transaction.prototype.getEvent = function() {
      return this.getTask().getEvent();
    };

    Transaction.prototype.getTo = function() {
      return this.getTask().getTo();
    };

    Transaction.prototype.setId = function(_id) {
      this._id = _id != null ? _id : this.generateId();
    };

    Transaction.prototype.getId = function() {
      return this._id;
    };

    Transaction.prototype.setTask = function(_task) {
      this._task = _task;
    };

    Transaction.prototype.getTask = function() {
      return this._task;
    };

    Transaction.prototype.setHistory = function(_history) {
      this._history = _history != null ? _history : [];
    };

    Transaction.prototype.getHistory = function() {
      return this._history;
    };

    Transaction.prototype.loadTasks = function(tasks) {
      var i, len, results, t;
      if (tasks == null) {
        tasks = [];
      }
      results = [];
      for (i = 0, len = tasks.length; i < len; i++) {
        t = tasks[i];
        results.push(this._history.push(new Task(t)));
      }
      return results;
    };

    return Transaction;

  })();

  module.exports = Transaction;

}).call(this);

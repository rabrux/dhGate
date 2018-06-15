var FSHelper, TaskClient, Transaction, moment, path, socket;

path = require('path');

moment = require('moment');

socket = require('socket.io-client');

FSHelper = require('../lib/FSHelper');

Transaction = require('../core/Transaction');

TaskClient = (function() {
  function TaskClient(app) {
    if (!(app != null ? app.uri : void 0) || !(app != null ? app.modules : void 0) || !(app != null ? app.task : void 0)) {
      throw Error('missing params');
    }
    this._uri = app.uri;
    this._modules = app.modules;
    this._task = app.task;
    this._timeout = app.timeout || 10;
    this.validate();
    this.run();
  }

  TaskClient.prototype.validate = function() {
    var e, fsh, taskPath;
    fsh = new FSHelper(this.modulesPath());
    if (!fsh.isDirectory()) {
      throw Error('modules path is not a directory');
    }
    taskPath = path.join(process.cwd(), this.modulesPath(), this.moduleFile());
    try {
      return this._process = require(taskPath);
    } catch (error) {
      e = error;
      throw Error("task " + taskPath + " is not available");
    }
  };

  TaskClient.prototype.run = function() {
    var it;
    this._socket = socket(this.getUri());
    it = this;
    this._socket.on('connect', function() {
      this.emit('register', it.getTask());
      it.extendTimeout();
      return it.tick();
    });
    return this._socket.on('task', function(transaction) {
      it.extendTimeout();
      transaction = new Transaction(transaction);
      return it._process(it.socket(), transaction);
    });
  };

  TaskClient.prototype.extendTimeout = function() {
    return this.timeout = moment().add(this._timeout, 'minutes');
  };

  TaskClient.prototype.tick = function() {
    var it;
    it = this;
    return setInterval(function() {
      var diff;
      diff = moment().diff(it.timeout, 'minutes');
      if (diff >= 0) {
        it.socket().emit('shutdown', it.getTask());
        return process.exit(1);
      }
      return it.tick();
    }, 60000).unref();
  };

  TaskClient.prototype.getUri = function() {
    return this._uri;
  };

  TaskClient.prototype.getTask = function() {
    return this._task;
  };

  TaskClient.prototype.modulesPath = function() {
    return this._modules;
  };

  TaskClient.prototype.moduleFile = function() {
    return this._task.split(':').join(path.sep);
  };

  TaskClient.prototype.socket = function() {
    return this._socket;
  };

  return TaskClient;

})();

module.exports = TaskClient;

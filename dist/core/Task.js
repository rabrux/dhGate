(function() {
  var Task, rs;

  rs = require('randomstring');

  Task = (function() {
    function Task(task, sockId) {
      this.setId(task._id);
      this.setTo(task.to);
      this.setEvent(task.event);
      this.setParams(task.params);
      this.setOnSuccess(task._onSuccess || sockId);
      this.setOnError(task._onError || sockId);
    }

    Task.prototype.generateId = function() {
      return rs.generate({
        length: 15
      });
    };

    Task.prototype.setTo = function(to) {
      this.to = to;
    };

    Task.prototype.getTo = function() {
      return this.to;
    };

    Task.prototype.setEvent = function(event) {
      this.event = event != null ? event : 'task';
    };

    Task.prototype.getEvent = function() {
      return this.event;
    };

    Task.prototype.setId = function(_id) {
      this._id = _id != null ? _id : this.generateId();
    };

    Task.prototype.getId = function() {
      return this._id;
    };

    Task.prototype.setParams = function(params) {
      this.params = params;
    };

    Task.prototype.getParams = function() {
      return this.params;
    };

    Task.prototype.setOnSuccess = function(onSuccess) {
      if (typeof onSuccess === 'string') {
        return this._onSuccess = {
          to: onSuccess,
          event: this.getTo() + ':success'
        };
      }
      return this._onSuccess = onSuccess;
    };

    Task.prototype.getOnSuccess = function() {
      return this._onSuccess;
    };

    Task.prototype.successTo = function() {
      return this.getOnSuccess().to;
    };

    Task.prototype.successEvent = function() {
      return this.getOnSuccess().event;
    };

    Task.prototype.setOnError = function(onError) {
      if (typeof onError === 'string') {
        return this._onError = {
          to: onError,
          event: this.getTo() + ':error'
        };
      }
      return this._onError = onError;
    };

    Task.prototype.getOnError = function() {
      return this._onError;
    };

    Task.prototype.errorTo = function() {
      return this.getOnError().to;
    };

    Task.prototype.errorEvent = function() {
      return this.getOnError().event;
    };

    return Task;

  })();

  module.exports = Task;

}).call(this);

(function() {
  var FSHelper, Transaction, _process, _timeout, client, e, fsh, moment, path, taskPath, tick, url;

  path = require('path');

  moment = require('moment');

  Transaction = require('./Transaction');

  FSHelper = require('../lib/FSHelper');

  if (!process.env.APP_PORT || !process.env.APP_ROOT || !process.env.APP_NAME) {
    throw 'app wrong';
  }

  url = 'http://localhost:' + process.env.APP_PORT;

  fsh = new FSHelper(process.env.APP_ROOT);

  if (!fsh.isDirectory()) {
    throw 'APP_ROOT path is not a directory';
  }

  taskPath = path.join(process.cwd(), process.env.APP_ROOT, process.env.APP_NAME.split(':').join(path.sep));

  try {
    _process = require(taskPath);
  } catch (error) {
    e = error;
    throw "task " + taskPath + " is not available";
  }

  client = require('socket.io-client')(url);

  _timeout = moment().add(process.env.APP_TIMEOUT || 10, 'minutes');

  client.on('connect', function() {
    console.log('task client connected', process.env.APP_NAME);
    this.emit('register', process.env.APP_NAME);
    return tick();
  });

  client.on('task', function(trans) {
    _timeout = moment().add(process.env.APP_TIMEOUT || 10, 'minutes');
    trans = new Transaction(trans);
    return _process(client, trans);
  });

  tick = function() {
    return setInterval(function() {
      var diff;
      diff = moment().diff(_timeout, 'minutes');
      if (diff >= 0) {
        client.emit('shutdown', process.env.APP_NAME);
        return process.exit(1);
      }
      return tick();
    }, 60000).unref();
  };

}).call(this);

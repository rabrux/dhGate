(function() {
  var args, flags;

  args = require('args');

  args.command('init', 'Initialize dhGate project').command('task', 'Creates new task file').command('update', 'After reinitialize project, it rebuilds ecosystem file').examples([
    {
      usage: 'dhgate init --src source --dist bundle --port 1234',
      description: 'initializes new project on directory \"source\" and listen port \"1234\"'
    }, {
      usage: 'dhgate task --name auth:login --timeout 2',
      description: 'creates task file on root app directory with timeout equals to 2 minutes, if root directory is "app" the result wound be a file on path "app/auth/login.coffee"'
    }
  ]);

  flags = args.parse(process.argv);

}).call(this);

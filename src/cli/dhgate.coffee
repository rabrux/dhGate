args = require 'args'

args
  .command 'init', 'Initialize dhGate project'
  .command 'task', 'Creates new task file'
  .examples [
    {
      usage : 'dhgate init --app app --port 1234'
      description : 'initializes new project on directory \"app\" and listen port \"1234\"'
    }
    {
      usage : 'dhgate task --name auth:login'
      description : 'creates task file on root app directory, if root directory is "app" the result wound be a file on path "app/auth/login.coffee"'
    }
  ]

flags = args.parse process.argv

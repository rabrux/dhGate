args   = require 'args'
path   = require 'path'
fs     = require 'fs'
colors = require 'colors'

args
  .option 'app', 'Application directory base path', 'app'
  .option 'port', 'Application listen port', 1337
  .example 'dhgate init --app app --port 1234', 'initializes new project on directory \"app\" and listen port \"1234\"'

flags = args.parse process.argv

# check app directory
if not fs.existsSync( flags.app )
  fs.mkdirSync flags.app

console.log '->'.green, 'Application directory created at', flags.app.cyan

# write config file
fs.writeFileSync '.dhgate.json', JSON.stringify( { root : flags.app, port : flags.port }, null, 2 )

console.log '->'.green, 'Configuration file created as', '.dhgate.json'.cyan

gatePath = path.join process.cwd(), flags.app, 'gate.coffee'

gateContent = "{ dhGate } = require '../bundle/dhGate'\npath       = require 'path'\n\n\# config file\nconfig = require '../.dhgate.json'\n\n\# init gate\ngate = new dhGate config.port,\n  root : path.join __dirname\n\ngate.on 'connect', ( socket ) ->\n  console.log 'client connected', socket.id\n"

fs.writeFileSync gatePath, gateContent
console.log '->'.green, 'Gate index file created at', flags.app.cyan


args   = require 'args'
path   = require 'path'
fs     = require 'fs'
colors = require 'colors'

# validate config file
try
  config = require path.join process.cwd(), '.dhgate.json'
catch
  console.log "\n  Application is not initialized yet, please run init command before create task.".red
  process.exit 2

# get current ecosystem file
ecoPath = path.join process.cwd(), 'ecosystem.json'
try
  ecosystem = require ecoPath
catch
  ecosystem =
    apps : []

for app in ecosystem.apps
  app.env.APP_ROOT = config.root
  app.env.APP_PORT = config.port

fs.writeFileSync ecoPath, JSON.stringify( ecosystem, null, 2 )
console.log '->'.green, 'updated ecosystem file'

# args
#   .option 'app', 'Application directory base path', 'app'
#   .option 'port', 'Application listen port', 1337
#   .example 'dhgate init --app app --port 1234', 'initializes new project on directory \"app\" and listen port \"1234\"'

# flags = args.parse process.argv

# # check app directory
# if not fs.existsSync( flags.app )
#   fs.mkdirSync flags.app

# console.log '->'.green, 'Application directory created at', flags.app.cyan

# # write config file
# fs.writeFileSync '.dhgate.json', JSON.stringify( { root : flags.app, port : flags.port }, null, 2 )

# console.log '->'.green, 'Configuration file created as', '.dhgate.json'.cyan

# gatePath = path.join process.cwd(), flags.app, 'gate.coffee'

# gateContent = "{ dhGate } = require '../bundle/dhGate'\npath       = require 'path'\n\n\# config file\nconfig = require '../.dhgate.json'\n\n\# init gate\ngate = new dhGate config.port,\n  root : path.join __dirname\n\ngate.on 'connect', ( socket ) ->\n  console.log 'client connected', socket.id\n"

# fs.writeFileSync gatePath, gateContent
# console.log '->'.green, 'Gate index file created at', flags.app.cyan

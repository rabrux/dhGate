args   = require 'args'
path   = require 'path'
fs     = require 'fs'
colors = require 'colors'
shell  = require 'shelljs'

# validate config file
try
  config = require path.join process.cwd(), '.dhgate.json'
catch
  console.log "\n  Application is not initialized yet, please run init command before create task.".red
  process.exit 2

args
  .option 'name', 'Task name in format <module>:<task>', undefined
  .option 'timeout', 'Task timeout', 10
  .example 'dhgate task --name auth:login --timeout 2', 'creates task file on root app directory with timeout equals to 2 minutes, if root directory is "app" the result wound be a file on path "app/auth/login.coffee"'

flags = args.parse process.argv

# validate task name
if not flags.name
  console.log "\n  option --name can not be empty".red
  args.showHelp()
  process.exit 2

if flags.name.split( ':' ).length isnt 2
  console.log "\n  task name needs to be formated like <module>:<task> see example in help".red
  args.showHelp()
  process.exit 2

# check module directory
parts = flags.name.split ':'
module = parts.shift()
modulePath = path.join process.cwd(), config.root, 'modules', module
if not fs.existsSync( modulePath )
  fs.mkdirSync modulePath
  console.log '->'.green, 'module', module.cyan, 'created.'

# create task file
task = parts.shift()
taskPath = path.join modulePath, task + '.coffee'

# assets potential paths for dev and prod
assetsPotentialPaths = [
  path.join process.cwd(), 'node_modules', 'dhgate', 'assets'
  path.join process.cwd(), 'assets'
]

# copy gate base code
for p in assetsPotentialPaths
  if fs.existsSync( p )
    shell.cp path.join( p, 'task.coffee' ), taskPath
    break

console.log '->'.green, 'task', task.cyan, 'created for module', module.cyan

# add function to ecosystem pm2 config file
ecoPath = path.join process.cwd(), 'tasks.json'
# if not fs.existsSync( ecoPath )
try
  ecosystem = require ecoPath
catch
  ecosystem =
    apps : []

# create task entry
task =
  name   : flags.name
  script : path.join config.dist, 'client.js'
  merge_logs  : true
  autorestart : false
  watch       : true
  env :
    APP_NAME    : flags.name
    APP_ROOT    : path.join config.dist, 'modules'
    APP_PORT    : config.port
    APP_TIMEOUT : flags.timeout

# entry exists
entry = ecosystem.apps.filter( ( el ) -> el.name is flags.name ).shift()

if not entry
  ecosystem.apps.push task
else
  index = ecosystem.apps.indexOf entry
  ecosystem.apps.splice index, 1, task

fs.writeFileSync ecoPath, JSON.stringify( ecosystem, null, 2 )
console.log '->'.green, 'task', flags.name.cyan, 'added to ecosystem pm2 config file'

path   = require 'path'
fs     = require 'fs'
colors = require 'colors'

# validate config file
try
  config = require path.join process.cwd(), '.dhgate.json'
catch
  console.log "\n  Application is not initialized yet, please run init command before create task.".red
  process.exit 2

# ecosystem path
ecoPath = path.join process.cwd(), 'ecosystem.json'

# init empty ecosystem
ecosystem =
  apps : []

# recursive load modules
console.log '->'.green, 'looking for hand added modules'

modules = path.join process.cwd(), config.root, 'modules'
files   = fs.readdirSync modules

# TaskClient script path
taskClientPotentialsPath = [
  path.join 'node_modules', 'dhgate', 'dist', 'core', 'TaskClient.js'
  path.join 'dist', 'core', 'TaskClient.js'
]

taskClientPath = undefined
for p in taskClientPotentialsPath
  if fs.existsSync( p )
    taskClientPath = p
    break

for file in files
  fullpath = path.join modules, file
  f = fs.lstatSync fullpath
  if f.isDirectory()
    console.log '->'.green, 'load module', file.cyan
    tasks = fs.readdirSync fullpath
    for task in tasks
      taskName = file + ':' + path.parse( task ).name
      # create task entry
      task =
        name   : taskName
        script : taskClientPath
        merge_logs  : true
        autorestart : false
        watch       : true
        env :
          APP_NAME    : taskName
          APP_ROOT    : path.join config.dist, 'modules'
          APP_PORT    : config.port
          APP_TIMEOUT : 2

      # entry exists
      entry = ecosystem.apps.filter( ( el ) -> el.name is taskName ).shift()

      if not entry
        ecosystem.apps.push task
        console.log "\t->".green, 'task', taskName.cyan, 'added to ecosystem pm2 config file'
      else
        index = ecosystem.apps.indexOf entry
        ecosystem.apps.splice index, 1, task

# write ecosystem file
fs.writeFileSync ecoPath, JSON.stringify( ecosystem, null, 2 )
console.log '->'.green, 'ecosystem updated with hand added modules'

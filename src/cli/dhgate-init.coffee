args   = require 'args'
path   = require 'path'
fs     = require 'fs'
shell  = require 'shelljs'
colors = require 'colors'

exec     = require( 'child_process' ).spawn
execSync = require( 'child_process' ).spawnSync
stream   = require 'stream'

args
  .option 'src', 'app source directory', 'src'
  .option 'dist', 'app production directory', 'dist'
  .option 'port', 'app listen port', 1337
  .example 'dhgate init --src source --dist bundle --port 1234', 'initializes new project on directory \"source\" and listen port \"1234\"'

flags = args.parse process.argv

configure = ->
  # check src directory
  fullPath = path.join flags.src, 'modules'
  if not fs.existsSync( fullPath )
    shell.mkdir '-p', fullPath

  console.log '->'.green, 'application directory created at', flags.src.cyan

  # write config file
  fs.writeFileSync '.dhgate.json', JSON.stringify( { root : flags.src, dist: flags.dist, port : flags.port }, null, 2 )

  console.log '->'.green, 'configuration file created as', '.dhgate.json'.cyan

  # copy base gate to source dir
  # gatePath = path.join process.cwd(), flags.src, 'gate.coffee'
  srcPath = path.join process.cwd(), flags.src

  # assets potential paths for dev and prod
  assetsPotentialPaths = [
    path.join process.cwd(), 'node_modules', 'dhgate', 'assets'
    path.join process.cwd(), 'assets'
  ]

  # copy gate base code
  for p in assetsPotentialPaths
    if fs.existsSync( p )
      shell.cp path.join( p, 'gate.coffee' ), srcPath
      break

  console.log '->'.green, 'gate index file created at', flags.src.cyan

  # copy client to base code
  for p in assetsPotentialPaths
    if fs.existsSync( p )
      shell.cp path.join( p, 'client.coffee' ), srcPath

  console.log '->'.green, 'client index file created at', flags.src.cyan

  # copy gulpfile
  for p in assetsPotentialPaths
    if fs.existsSync( p )
      shell.cp path.join( p, 'Gulpfile.coffee' ), process.cwd()

  console.log '->'.green, 'gulpfile created, use "gulp" command to compile your app and "gulp dev" to watch and recompile'

  # add dev packages to package.json
  console.log '->'.green, 'installing node dev dependencies'
  child = exec cmd, [ 'install', '--save-dev', 'gulp', 'gulp-coffee', 'gulp-watch', 'coffeescript' ]
  child.stderr.on 'data', ( data ) ->
    message = data.toString()
    if not /npm|WARN|deprecated/g.test( message )
      console.error '->'.yellow, message
  child.on 'close', ( code ) ->
    console.log '->'.green, 'dev dependencies installed'

# verify npm file
packageFile = path.join process.cwd(), 'package.json'
cmd = if /^win/.test( process.platform ) then 'npm.cmd' else 'npm'
if not fs.existsSync( packageFile )
  child = exec cmd, [ 'init' ],
    stdio : [
      0
      'pipe'
      'pipe'
    ]
  child.stdout.on 'data', ( data ) ->
    process.stdout.write data.toString()
  child.stderr.on 'data', ( data ) ->
    console.log 'err', data.toString()
  child.on 'close', ( code ) ->
    configure()
else
  configure()

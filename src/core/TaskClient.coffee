path   = require 'path'
moment = require 'moment'

# core libs
Transaction = require './Transaction'
FSHelper    = require '../lib/FSHelper'

if not process.env.APP_PORT or not process.env.APP_ROOT or not process.env.APP_NAME
  throw 'app wrong'

url = 'http://localhost:' + process.env.APP_PORT

# check if modules directory exists
fsh = new FSHelper process.env.APP_ROOT
if not fsh.isDirectory()
  throw 'APP_ROOT path is not a directory'

# check if task file exists
taskPath = path.join process.cwd(), process.env.APP_ROOT, process.env.APP_NAME.split( ':' ).join path.sep
try
  _process = require taskPath
catch e
  throw "task #{ taskPath } is not available"

# connect to server
client = require( 'socket.io-client' ) url

# calculate timeout
_timeout = moment().add( process.env.APP_TIMEOUT || 10, 'minutes' )

client.on 'connect', ->
  console.log 'task client connected', process.env.APP_NAME
  @emit 'register', process.env.APP_NAME
  tick()

client.on 'task', ( trans ) ->
  _timeout = moment().add( process.env.APP_TIMEOUT || 10, 'minutes' )
  trans = new Transaction trans
  _process client, trans

# timeout
tick = ->
  setInterval( ->
    diff = moment().diff _timeout, 'minutes'
    if diff >= 0
      client.emit 'shutdown', process.env.APP_NAME
      return process.exit( 1 )
    tick()
  , 60000 ).unref()

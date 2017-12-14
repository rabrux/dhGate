{ dhGate } = require '../bundle/dhGate'
path       = require 'path'

# config file
config = require '../.dhgate.json'

# init gate
gate = new dhGate config.port,
  root : path.join __dirname

gate.on 'connect', ( socket ) ->
  console.log 'client connected', socket.id

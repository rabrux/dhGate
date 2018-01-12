{ dhGate } = require 'dhgate'
path       = require 'path'

# config file
config = require '../.dhgate.json'

# init gate
gate = new dhGate config.port

gate.on 'connect', ( socket ) ->
  console.log 'client connected', socket.id

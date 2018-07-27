###
# main server file
###

# packages
io = require 'socket.io'

# environment variables
port = process.env.PORT || 1337

# socket server configuration
io = io port

# protocol
io.use require( './protocol/core' ) io
#require( './protocol/core' ) io

io.on 'connection', ( socket ) ->
  console.log 'client connected', socket.id


console.log 'magic happends on', port

module.exports = io



###
# dhgate main file
###

# external packages
fs   = require 'fs'
io   = require 'socket.io'
path = require 'path'
rsa  = require 'node-rsa'

# base
protocol = require './protocol'

class dhGate extends io

  constructor : ( srv, opts ) ->
    super srv, opts

    @_tasks = []

    # load or generate rsa keys
    #@loadKeys()
    ###
    if not process.env.KEY_FILE
      @_key = new rsa b: 512
      @saveKeys()
    ###

    # init protocol
    @use protocol @

  saveKeys : ->
    return false if not @_key

    keysFile = path.join process.cwd(), '.keys'
    
    keys =
      public  : @_key.exportKey 'public'
      private : @_key.exportKey 'private'

    try
      stats = fs.statSync keysFile
      console.log stats
    catch e

    if not stats
      fs.writeFileSync keysFile, JSON.stringify( keys, null, 2 )

module.exports = dhGate


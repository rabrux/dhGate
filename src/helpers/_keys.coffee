# packages
fs   = require 'fs'
path = require 'path'
RSA  = require 'node-rsa'

class Keys

  constructor : ( @_filePath, @_b = 512 ) ->
    # bad constructor
    throw new Error 'filepath argument is required' if not @_filePath

    # level up control
    @_upLevel = 0

    # path not exists
    throw new Error 'inaccessible filepath' if not @exist( @_filePath )

    @load()

  load : ->
    file = @_stat @getFilename()
    if not file
      @generate()
    else
      @loadKeysFromFile()

  loadKeysFromFile : ->
    data = fs.readFileSync @getFilename()
    try
      data = JSON.parse data.toString()
      @_key = new RSA()
      @_key.importKey data.private, 'private'
      @_key.importKey data.public, 'public'
    catch e
      @generate()

  validate : ->
    not @_key.isEmpty()

  generate : ->
    @_key = new RSA b: @_b
    @save()

  save : ->
    filename = @getFilename()
    file     = @_stat filename
    if file
      fs.truncateSync filename
    fs.writeFileSync filename, @toJSON()

  toJSON : ->
    keys =
      private : @_key.exportKey 'private'
      public  : @_key.exportKey 'public'

    JSON.stringify keys, null, 2

  getFilename : ->
    if @_upLevel is 0
      stats = @_stat @_filePath
      if stats.isDirectory()
        return path.join @_filePath, '.keys'
      else if stats.isFile()
        return @_filePath
    else
      return @_filePath

  exist : ( _path ) ->
    pathExist = @_stat _path
    if not pathExist and @_upLevel is 0
      @_upLevel++
      return @_stat path.join _path, '..'

    pathExist

  _stat : ( _path ) ->
    try
      return fs.lstatSync _path
    catch e
      return false

module.exports = Keys


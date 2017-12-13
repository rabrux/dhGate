fs = require 'fs'

class FSHelper

  constructor : ( @_path ) ->

  isDirectory : ->
    stats = @pathStats @getPath()
    return false if not stats
    stats?.isDirectory()

  isFile : ->
    stats = @pathStats @getPath()
    return false if not stats
    stats?.isFile()

  pathStats : ->
    try
      return fs.lstatSync @getPath()
    catch e
      return false

  # getters and setters
  setPath : ( @_path ) ->
  getPath : -> @_path

module.exports = FSHelper

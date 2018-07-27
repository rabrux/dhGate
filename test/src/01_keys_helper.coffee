# packages
{ Keys } = require '../../dist/helpers'
fs       = require 'fs'
path     = require 'path'
should   = require( 'chai' ).should()

describe 'helper Keys', ->

  it 'helper exists', ( done ) ->
    should.exist Keys
    done()

  it 'create instance error: missing _path', ( done ) ->
    ( () -> new Keys() ).should.throw Error, 'filepath argument is required'
    done()

  it 'create instance error: inaccessible _path', ( done ) ->
    _path = path.join process.cwd(), '_keys', '_secondLevel'
    ( () -> new Keys _path ).should.throw Error, 'inaccessible filepath'
    done()

  it 'create new keys default filename (.keys)', ( done ) ->
    _path = process.cwd()
    keyFile = path.join _path, '.keys'
    key = new Keys _path
    key.validate().should.not.be.equal false
    done()

  it 'create new keys custom filename', ( done ) ->
    _path = path.join process.cwd(), 'custom.keys'
    key   = new Keys _path
    key.validate().should.not.be.equal false
    done()

  it 'load keys suceess: default keys file loaded', ( done ) ->
    _path = path.join process.cwd()
    key   = new Keys _path
    key.validate().should.be.equal true
    done()

  it 'remove test keys files', ( done ) ->
    fs.unlinkSync path.join( process.cwd(), '.keys' )
    fs.unlinkSync path.join( process.cwd(), 'custom.keys' )
    done()


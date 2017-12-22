class Collection

  constructor : ( @_type, @_collection = [] ) ->
    if not @_type
      throw Error 'type needs to be specified on first argument of constructor'
    if @_collection instanceof Array is false
      throw Error 'collection must be an array'

  set : ( @_collection ) ->
  get : -> @_collection

  findByKey : ( key, value ) ->
    if not value
      return @_collection.filter ( el ) -> el[ key ]

    @_collection.filter ( el ) -> el[ key ] is value

  register : ( item ) ->
    if item instanceof @_type is false
      throw Error 'item is not instance of @_type'
    @_collection.push item

  remove : ( items ) ->
    if items instanceof Array
      for i in items
        @remove i
    if items instanceof @_type
      index = @_collection.indexOf items
      @_collection.splice index, 1
    @

module.exports = Collection


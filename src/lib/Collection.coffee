class Collection

  constructor : ( @_type, @_collection = [] ) ->
    if not @_type
      throw Error 'type needs to be specified on first argument of constructor'
    if @_collection instanceof Array is false
      throw Error 'collection must be an array'

  set : ( @_collection ) ->
  get : -> @_collection

  find : ( item ) ->
    @_collection.filter ( el ) -> el is item

  findByKey : ( key, value ) ->
    keys = key.split '.'
    if not value
      return @_collection.filter ( el ) ->
        e = el
        for k in keys
          e = e[ k ]
        e

    @_collection.filter ( el ) ->
      e = el
      for k in keys
        e = e[ k ]
      e is value

  register : ( item ) ->
    if @_type instanceof Object is true
      if item instanceof @_type is false
        throw Error 'item is not instance of @_type'
    else
      if typeof item isnt @_type
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


rs = require 'randomstring'

class Task

  constructor : ( task, sockId ) ->

    @setId        task._id
    @setTo        task.to
    @setEvent     task.event
    @setParams    task.params
    @setOnSuccess task._onSuccess || sockId
    @setOnError   task._onError   || sockId

  generateId : -> rs.generate length : 15
  
  # setters and getters
  setTo : ( @to ) ->
  getTo : -> @to

  setEvent : ( @event = 'task' ) ->
  getEvent : -> @event

  setId : ( @_id = @generateId() ) ->
  getId : -> @_id

  setParams : ( @params ) ->
  getParams : -> @params

  setOnSuccess : ( onSuccess ) ->
    if typeof onSuccess is 'string'
      return @_onSuccess =
        to    : onSuccess
        event : @getTo() + ':success'
    @_onSuccess = onSuccess
  getOnSuccess : -> @_onSuccess

  setOnError : ( onError ) ->
    if typeof onError is 'string'
      return @_onError =
        to    : onError
        event : @getTo() + ':error'
    @_onError = onError
  getOnError : -> @_onError

module.exports = Task

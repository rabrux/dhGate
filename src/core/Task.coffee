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

  setResponseEvent : ( ev, sufix = ':success' ) ->
    if typeof ev is 'string'
      eve =
        to : ev
      if ev.split( ':' ).length is 2
        eve.event = 'task'
      else
        eve.event = @getTo() + sufix
      return eve
    ev

  setOnSuccess : ( onSuccess ) ->
    @_onSuccess = @setResponseEvent onSuccess

  getOnSuccess : -> @_onSuccess

  successTo : -> @getOnSuccess().to
  successEvent : -> @getOnSuccess().event

  setOnError : ( onError ) ->
    @_onError = @setResponseEvent onSuccess, ':error'

  getOnError : -> @_onError

  errorTo : -> @getOnError().to
  errorEvent : -> @getOnError().event

module.exports = Task

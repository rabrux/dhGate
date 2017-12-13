rs = require 'randomstring'

Task = require './Task'

class Transaction

  constructor : ( transaction ) ->

    # if transaction is a task
    if transaction instanceof Task
      @setId()
      @setTask transaction
      @setHistory()
    else
      @setId transaction._id
      @setTask new Task transaction._task
      @setHistory()
      @loadTasks transaction._history

  pushTask : ( task ) ->
    @_history.push @getTask()
    if not task._onSuccess
      task._onSuccess = @getTask().getOnSuccess()
    if not task._onError
      task._onError = @getTask().getOnError()
    @setTask task

  generateId : -> rs.generate length : 15

  getTo : -> @getTask().getTo()
  getEvent : -> @getTask().getEvent()

  setId : ( @_id = @generateId() ) ->
  getId : -> @_id

  setTask : ( @_task ) ->
  getTask : -> @_task

  setHistory : ( @_history = [] ) ->
  getHistory : -> @_history

  loadTasks : ( tasks = [] ) ->
    for t in tasks
      @_history.push new Task t

module.exports = Transaction

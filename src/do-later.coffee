mongoPool = require 'mongo-pool2'

now = ->
  + new Date()

module.exports = class DoLater
  constructor: (@config) ->
    @_runningCheck = false
    @_poolReady = false
    @_buffer = []
    @_eventsHub = new(require('events').EventEmitter)
    @_pool = mongoPool.create @config, =>
      @_onPoolReady()
    @_checkInterval = @config.interval or 1000
    @_pollInterval = 100

  doLater: (waitSec, jobName) ->
    params = Array::slice.call(arguments, 1)
    tm = now()
    console.log 'DoLater adding job', jobName, 'at', Date(tm)
    job = { createdAt: tm, when: tm + waitSec * 1000, jobName, params }
    if not @_poolReady
      @_addBuffered job
    else
      @_addJob job

  _addBuffered: (job) ->
    @_buffer.push job

  _onPoolReady: ->
    @_poolReady = true
    for jobSpec in @_buffer
      @_addJob jobSpec
    @_buffer = []
    @_check()

  _coll: ->
    conn = @_pool.acquire()
    conn.collection @config.collection

  _addJob: (job) ->
    if not @_poolReady
      return @_addBuffered job
    coll = @_coll()
    coll.insert job, ->
      tm = now()
      console.log 'DoLater job', job.jobName, 'added at', Date(tm)

  _check: ->
    checkFn = @_check.bind @
    if @_runningCheck
      return setTimeout checkFn, @_pollInterval
    @_runningCheck = true
    coll = @_coll()
    query = when: $lt: now()
    sort = [['when', 1], ['createdAt', 1]]
    coll.findAndRemove query, sort, (err, job) =>
      @_runningCheck = false
      if err
        console.log 'DoLater error', err
        setTimeout checkFn, @_pollInterval
      else if job
        @_onJob job
        setTimeout checkFn, @_pollInterval
      else
        setTimeout checkFn, @_checkInterval

  _onJob: (job) ->
    tm = now()
    console.log 'DoLater executing job', job.jobName, 'at', Date(tm)
    @_eventsHub.emit.apply @_eventsHub, job.params

  on: (jobName, fn) ->
    @_eventsHub.on jobName, fn
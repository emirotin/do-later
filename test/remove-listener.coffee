DoLater = require('../src/do-later')
testsCommon = require('./common')

describe 'DoLater', ->
  beforeEach (done) ->
    testsCommon.beforeEach(done)

  it 'should properly handle removing vent listeners', (done) ->
    res = 0
    scheduler = testsCommon.createDoLater()

    listener1 = ->
      res = 1
    listener2 = ->
      res = 2
    scheduler.on 'task', listener1
    scheduler.off 'task', listener1
    scheduler.on 'task', listener2

    scheduler.doLater 1, 'task'

    setTimeout ->
      res.should.equal 0
    , 100

    setTimeout ->
      res.should.equal 2
      done()
    , 1500

DoLater = require('../src/do-later')
testsCommon = require('./common')

describe 'DoLater', ->
  beforeEach (done) ->
    testsCommon.beforeEach(done)

  it 'should run with given timing', (done) ->
    res = 0
    scheduler = testsCommon.createDoLater()

    scheduler.on 'addThree', (a, b, c) ->
      res += a + b + c
      console.log 'job addThree executed with params', a, b, c

    scheduler.doLater 10, 'addThree', 1, 2, 3
    scheduler.doLater 3, 'addThree', 10, 20, 30

    setTimeout ->
      res.should.equal 0
    , 1000

    setTimeout ->
      res.should.equal 60
    , 6000

    setTimeout ->
      res.should.equal 66
      done()
    , 12000

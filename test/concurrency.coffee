DoLater = require('../src/do-later')
testsCommon = require('./common')

describe 'DoLater', ->
  beforeEach (done) ->
    testsCommon.beforeEach(done)

  it 'should only handle tasks it\'s subscribed to', (done) ->
    res1 = 0
    res2 = 0
    scheduler1 = testsCommon.createDoLater()
    scheduler2 = testsCommon.createDoLater()

    scheduler1.on 'task1', ->
      console.log 'task1 executed'
      res1 += 1

    scheduler1.doLater 1, 'task1'
    scheduler2.doLater 1, 'task2'
    scheduler1.doLater 1, 'task1'

    setTimeout ->
      res1.should.equal 0
      res2.should.equal 0
    , 100

    setTimeout ->
      res1.should.equal 2
      res2.should.equal 0
      scheduler2.on 'task2', ->
        console.log 'task2 executed'
        res2 += 1
    , 2000

    setTimeout ->
      res2.should.equal 1
      done()
    , 3000

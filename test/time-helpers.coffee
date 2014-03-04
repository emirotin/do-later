DoLater = require('../src/do-later')
testsCommon = require('./common')

describe 'DoLater Time Helpers', ->
  it 'should define time helpers', (done) ->
    DoLater.SECOND.should.equal 1
    DoLater.MINUTE.should.equal 60
    DoLater.HOUR.should.equal 60*60
    DoLater.DAY.should.equal 60*60*24
    done()

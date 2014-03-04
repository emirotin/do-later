DoLater = require('../src/do-later')
mongoPool = require('mongo-pool2')

config =
  host: 'localhost'
  port: 27017
  db: '_dolater'
  collection: '_test'

module.exports =
  config: config

  createDoLater: ->
    new DoLater config
  
  beforeEach: (done) ->

    mongoPool.connect config, (err, db) ->
      if err
        return done err
      db.collection(config.collection).remove {}, done

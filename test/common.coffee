assert = require('assert')

config =
  host: 'localhost'
  port: 27017
  db: '_dolater'
  collection: '_test'

module.exports =
  config: config
  
  beforeEach: (done) ->
    mongoPool = require('mongo-pool2')

    mongoPool.connect config, (err, db) ->
      if err
        return done err
      db.collection(config.collection).remove {}, done
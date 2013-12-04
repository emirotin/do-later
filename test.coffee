assert = require('assert')
mongoPool = require('mongo-pool2')
DoLater = require('./index')

config =
  host: 'localhost'
  port: 27017
  db: 'likeandpay-qa'
  collection: '_test_dolater'

mongoPool.connect config, (err, db) ->
  assert.equal err, null
  db.collection(config.collection).remove {}, ->

res = 0

scheduler = new DoLater config

scheduler.on 'x', (a, b, c) ->
  res += a + b + c
  console.log 'job x executed with params', a, b, c

scheduler.doLater 10, 'x', 1, 2, 3
scheduler.doLater 1, 'x', 10, 20, 30

setTimeout ->
  assert.equal res, 66
  process.exit(0)
, 12000

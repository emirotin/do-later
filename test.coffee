require('coffee-script/register')
assert = require('assert')
mongoPool = require('mongo-pool2')
DoLater = require('./src/do-later')

config =
  host: 'localhost'
  port: 27017
  db: '_dolater'
  collection: '_test'

mongoPool.connect config, (err, db) ->
  assert.equal err, null
  db.collection(config.collection).remove {}, ->

res = 0

scheduler = new DoLater config

scheduler.on 'x', (a, b, c) ->
  res += a + b + c
  console.log 'job x executed with params', a, b, c

scheduler.doLater 10, 'x', 1, 2, 3
scheduler.doLater 3, 'x', 10, 20, 30

setTimeout ->
  console.log "assert.equal res, 0"
  assert.equal res, 0
  console.log "OK"
, 1000

setTimeout ->
  console.log "assert.equal res, 60"
  assert.equal res, 60
  console.log "OK"
, 6000

setTimeout ->
  console.log "assert.equal res, 66"
  assert.equal res, 66
  console.log "OK"
  process.exit(0)
, 12000

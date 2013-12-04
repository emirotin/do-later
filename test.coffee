DoLater = require('./index')

config =
  host: 'localhost'
  port: 27017
  db: 'likeandpay-qa'
  collection: '_test_dolater'

scheduler = new DoLater config

scheduler.on 'x', (a, b, c) ->
  console.log a + b + c

scheduler.on 'x', ->
  console.log 'XXX'


scheduler.doLater 10, 'x', 1, 2, 3
scheduler.doLater 1, 'x', 10, 20, 30

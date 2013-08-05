print = console.log
time = require 'time'
tz = "America/Los_Angeles"

s = 1000
m = 60 * s
h = 60 * m

getTempData = (rclient, tempKey, callback)->

  now = new time.Date()
  now.setTimezone tz
  start = new time.Date now.getFullYear(), now.getMonth(), now.getDate(), tz
  bgn = start.getTime() - 5 * m

  rclient.zrangebyscore tempKey, bgn, '+inf', (err, res) ->
    if err then throw err

    temp = res.map (datum) ->
      [x,y] = datum.split(',')
      hours = (new Date(parseFloat x) - start) / h
      {x: hours, y: y}

    callback
      current: [temp[temp.length - 1]]
      temp: temp

module.exports =
  getTempData: getTempData

main = ->
  redis = require 'redis'
  rclient = redis.createClient()

  getTempData rclient, 'tempdata', (data) ->
    print data

if require.main is module
  main()
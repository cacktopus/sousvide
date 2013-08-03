print = console.log

now = new Date()
start = new Date(now.getFullYear(), now.getMonth(), now.getDate())

s = 1000
m = 60 * s
h = 60 * m

module.exports.getTempData = (rclient, tempKey, callback)->
  rclient.zrangebyscore tempKey, '-inf', '+inf', (err, res) =>
    temp = res.map (datum) ->
      [x,y] = datum.split(',')
      time = (new Date(parseFloat x) - start) / h
      {x: time, y: y}

    callback
      current: [temp[temp.length - 1]]
      temp: temp
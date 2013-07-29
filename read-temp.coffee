fs = require 'fs'
print = console.log

'''
ce 01 4b 46 7f ff 02 10 4b : crc=4b YES
ce 01 4b 46 7f ff 02 10 4b t=28875
'''

line1 = /crc=.. YES/
line2 = /t=(\d+)/


getTemp = (cb) ->
  fs.readFile '/sys/bus/w1/devices/28-000004150749/w1_slave', {encoding: 'utf8'}, (err, data) ->
    if err then throw new Error err

    [one, two] = data.trim().split "\n"

    ma1 = one.match line1
    ma2 = two.match line2

    if ma1 and ma2
      temp = ma2[1]/1000.0
      cb temp
    else
      print "Problem with:"
      print data

    setTimeout (getTemp.bind null, cb), 250


main = ->
  getTemp (temp) ->
    print temp


main() if require.main is module




module.exports = getTemp
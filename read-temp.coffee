fs = require 'fs'
print = console.log

'''
ce 01 4b 46 7f ff 02 10 4b : crc=4b YES
ce 01 4b 46 7f ff 02 10 4b t=28875
'''

line1 = /crc=.. YES/
line2 = /t=(\d+)/


getTemp = (cb) ->
  cb 48.25
  setTimeout (getTemp.bind null, cb), 250


main = ->
  getTemp (temp) ->
    print temp


main() if require.main is module




module.exports = getTemp
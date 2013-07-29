fs = require 'fs'

#TODO: use open() and file descriptors so we can do a sync close on shutdown

wdog = '/dev/watchdog'

stream = undefined

feed = (stream) ->
  stream.write 'f', (err) ->
    if err then throw err

feedLoop = ->
  stream = fs.createWriteStream wdog
  feed stream
  id = setInterval (feed.bind null, stream), 1000
  return ->
    clearInterval id
    stream.end 'V', (err) ->
      if err then throw err
      console.log 'Watchdog stopped'

module.exports =
  feedLoop: feedLoop


feedLoop() if require.main is module
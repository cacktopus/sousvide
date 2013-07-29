utl = require('./utl')
util = require('util')
http = require('http')

log = console.log


readResp = (resp, cb) ->
  str = ''
  resp.on 'data', (chunk) ->
    str += chunk

  resp.on 'end', () ->
    cb(str)


procRes = (resp, cb) ->
  readResp(resp, cb)


procErr = (e) ->
  log e


procLines = (lines, sp) ->
  for line in lines
    log line
    args = line.args

    switch line.MSG

      when 'ACK'
        null

      when 'CMD'
        action = args.action
        if( action.length == 1 )
          log util.format('sending %s to board', action)
          sp.write('T' + action)    #This doesn't feel like the right place for this

      else
        log 'Unknown cmd'


putdata = (data, sp) ->
  cfg = utl.cfg.appeng
  if cfg.url and cfg.ID
    ts = utl.time()
    urlbase = 'http://%s/put?id=%s&time=%s&temp=%s'
    url = util.format urlbase, cfg.url, cfg.ID, ts, data
    log url

    cb = (resp) ->
      procRes resp, (data) ->
        lines = utl.strip(data)
        procLines(JSON.parse(lines), sp)

    http.get(url, cb).on('error', procErr)
  else
    console.warn "appengine not configured"

exports.putdata = putdata


main = () ->
  procLines []


if( require.main == module )
  main()
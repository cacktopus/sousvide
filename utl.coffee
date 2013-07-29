util = require('util')
cfg = require('./config.coffee')

log = console.log

time = () ->
    Date.now()/1000
    
strip = (s) ->
    s.replace(/^\s+/g,'').replace(/\s+$/g,'')
    
    

throttle = (delay, cb) ->
    last = 0
    return (all...)->
        now     = time()
        delta   = now - last

        if( delta > delay )
            last = now
            return cb all...
            
            
main = () ->
    cb = ()->log 'hey'
    setInterval(throttle(5,cb),1000)
    
if( require.main == module )
    main()
    
logfmt = (fmt, all...) ->
    console.log( util.format fmt, all... )
    

exports.timeout = (delay, cb) ->
    setTimeout cb, delay

exports.interval = (delay, cb) ->
    setInterval cb, delay

    
exports.throttle    = throttle
exports.time        = time
exports.cfg         = cfg
exports.strip       = strip
exports.logfmt      = logfmt
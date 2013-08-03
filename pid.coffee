utl = require('./utl')
util = require('util')
backbone = require 'backbone'
tempReadLoop = (require './read-temp')
print = console.log
fs = require 'fs'
appeng = require './appeng'
setupStdin = require './console_read'
app = require './app'
watchdog = require './watchdog'
_ = require 'underscore'
redis = require 'redis'
data = require './data'

#  73.0: dict(limit=0.40,  rng=0.05),
#  65.0: dict(limit=0.25,  rng=0.05),
#  62.0: dict(limit=0.23,  rng=0.04),
#  61.0: dict(limit=0.22,  rng=0.04),
#  60.0: dict(limit=0.215, rng=0.04),
#  59.0: dict(limit=0.21,  rng=0.04),
#  58.0: dict(limit=0.20,  rng=0.04),
#  57.0: dict(limit=0.195, rng=0.04),
#  56.0: dict(limit=0.190, rng=0.04),
#  55.0: dict(limit=0.187, rng=0.05),
#  54.0: dict(limit=0.185, rng=0.05),
#  44.0: dict(limit=0.10,  rng=0.03),


DATA =
  0.0: {limit: 0.00, rng: 0.00}
  85.0: {limit: 0.80, rng: 0.05}
  65.0: {limit: 0.25, rng: 0.05}
  60.0: {limit: 0.215, rng: 0.04}
  59.0: {limit: 0.21, rng: 0.04}
  55.0: {limit: 0.187, rng: 0.05}
  54.0: {limit: 0.185, rng: 0.05}
  44.0: {limit: 0.10, rng: 0.03}
  42.0: {limit: 0.095, rng: 0.03}

PID_THRESHOLD = 0.25

clamp = (lo, val, hi) ->
  if( val < lo )
    return lo
  if( val > hi )
    return hi
  return val

abs = Math.abs
floor = Math.floor

#PERIOD = 2.5 * 1000
PERIOD = 10 * 1000

headerGpio = '/sys/class/gpio/gpio25/value'
pumpGpio = '/sys/class/gpio/gpio17/value'

cook = ->
  print 'cook'
  fs.writeFile headerGpio, '1'

cool = ->
  print 'cool'
  fs.writeFile headerGpio, '0'

coolSync = ->
  fs.writeFileSync headerGpio, '0'

pumpOff = ->
  fs.writeFile pumpGpio, '0'

pumpOn = ->
  fs.writeFile pumpGpio, '1'

pumpOffSync = ->
  fs.writeFileSync pumpGpio, '0'


SousVide = backbone.Model.extend {

  defaults:
    setpoint: 59.0

    Kp: 0.2
    Ki: 0.05

    dn_l: 0.0
    up_l: 0.0

    PID_THRESHOLD: 0.25
    integral: 0.0
    bangstate: 0.0

    on: false

  initialize: () ->
    @preset @attributes.setpoint

    @on 'change:on', (model, value, options) ->
      @pump value

    @pump @get 'on'

    @rclient = redis.createClient()
    @tempKey = 'tempdata'

  preset: (point) ->
    dat = DATA[point]

    @set {setpoint: point}

    @set {
      up_l: dat.limit + dat.rng
      dn_l: dat.limit - dat.rng
    }

  pump: (value) ->
    if value then pumpOn() else pumpOff()


  pid: (temp, delta_t, t) ->
    attr = @attributes
    error = attr.setpoint - temp
    integral = attr.integral

    integral += error * delta_t
    output = attr.Kp * error + attr.Ki * integral
    integral = clamp -20, integral, 20

    if( abs output > 2.5 )
      integral = 0.0

    @set {integral: integral}
    output = clamp attr.dn_l, output, attr.up_l

    console.log {
      setpoint: attr.setpoint
      error: error
      integral: integral
      output: output
      delta_t: delta_t
      t: t
    }

    return output

  fullon: (t, temp) ->
    attr = @attributes
    error = attr.setpoint - temp

    if( abs(error) < PID_THRESHOLD )
      return null

    if( error > 0 )
      utl.logfmt 'full %d %d', t, temp
      return 1.0

    else
      utl.logfmt 'zero %d %d', t, temp
      return 0.0


  readloop: () ->
    t = 0.0
    t_prev = utl.time()

    logTemp = (time, temp) =>
      storeTime = time*1000
      val = "#{storeTime},#{temp}"
      @rclient.zadd @tempKey, storeTime, val, (err, res) ->
        if err then throw err
        print "redis: #{val}"

    log = _.throttle logTemp, (5 * 60 * 1000)

    return (temp, t_now) =>
      print t_now, temp
      log t_now, temp

      attr = @attributes
      @set {temp: temp}

      delta_t = t_now - t_prev
      t += delta_t

      if attr.on
        output = @fullon(t, temp)
        if output is null
          output = @pid(temp, delta_t, t)

        cookTime = output * PERIOD
        if cookTime >= PERIOD
          cook()

        else if cookTime <= 0
          cool()

        else
          cookTime = clamp 100, cookTime, (PERIOD - 100)
          cook()
          setTimeout cool, cookTime

        print "cookTime: #{cookTime}"

      else
        cool()

      t_prev = t_now

  getTempData: (cb) ->
    data.getTempData @rclient, @tempKey, cb
}


setup = ->
  print 'setup'

  temp = undefined
  tempReadLoop (data) ->
    temp = data
  getTemp = ->
    temp

  sv = new SousVide {setpoint: 55.0, getTemp: getTemp, on: false}

  f = sv.readloop()

  setInterval ->
    [temp, time] = [getTemp(), utl.time()]

    if temp?
      f temp, time
  , PERIOD

  sv


exitHandler = (wdogStop) ->
  wdogStop()
  #there is a timing issue here as this is async
  coolSync()
  pumpOffSync()
  process.exit()


handleSignals = (wdogStop) ->
  for sig in ['SIGINT', 'SIGTERM', 'SIGQUIT']
    process.on sig, (exitHandler.bind null, wdogStop)


setupConsole = (sv) ->
  setupStdin
    off: ->
      print 'off'
      sv.set {on: false}
      cool()

    on: ->
      print 'on'
      sv.set {on: true}

    pumpOff: ->
      print 'pump off'
      pumpOff()

    pumpOn: ->
      print 'pump on'
      pumpOn()

    temp: (T) ->
      print 'setpoint', T
      sv.preset T


setupAppengine = (sv) ->
  #log temp to appengine
  setInterval ->
    appeng.putdata (sv.get 'getTemp')()
  , utl.cfg.appeng.post_rate


main = () ->
  wdogStop = watchdog.feedLoop()
  handleSignals wdogStop

  sv = setup()

  setupConsole sv
  setupAppengine sv
  app.setup sv

if( require.main == module )
  main()

module.exports =
  setup: setup

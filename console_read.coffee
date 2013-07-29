sys = require 'sys'
stdin = process.openStdin()

print = console.log

setupStdin = (callbacks) ->
  stdin.addListener 'data', (d) ->
    cmd = d.toString().trim()
    switch
      when cmd == '0'
        callbacks.off()
      when cmd == '1'
        callbacks.on()
      when cmd == 'p'
        callbacks.pumpOn()
      when cmd == 'P'
        callbacks.pumpOff()
      when parseFloat cmd
        callbacks.temp parseFloat cmd

module.exports = setupStdin
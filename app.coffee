express = require 'express'
app = express()
getTemp = require './read-temp'
print = console.log
pid = require './pid'

tempdata =
  current: [
    x: 7.69
    y: 28.25
  ]
  temp: [{
    x: 0.02
    y: 59.00
  },{
    x: 7.69
    y: 28.25
  }]

setup = (sv) ->
  app.use express.bodyParser()
  app.use express.static 'html'

  app.get '/sousvide/:id', (req, res) ->
    res.send sv.toJSON()

  app.put '/sousvide/:id', (req, res) ->
    sv.set req.body
    res.send sv.toJSON()

  app.use (req, res) ->
    print '404', req.url, req.body
    res.send {}, 404

  app.get '/tempdata.json', (req, res) ->
    res.send tempdata

  app.listen 3000
  console.log 'listening'
  app

module.exports.setup = setup

express = require 'express'
app = express()
getTemp = require './read-temp'
print = console.log
pid = require './pid'

setup = (sv) ->
  app.use express.bodyParser()
  app.use express.static (__dirname + '/html')

  app.get '/sousvide/:id', (req, res) ->
    res.send sv.toJSON()

  app.put '/sousvide/:id', (req, res) ->
    sv.set req.body
    res.send sv.toJSON()

  app.get '/tempdata.json', (req, res) ->
    sv.getTempData (data) ->
      res.send data

  app.use (req, res) ->
    print '404', req.url, req.body
    res.send '', 404

  app.listen 3000
  console.log 'listening'
  app

module.exports.setup = setup

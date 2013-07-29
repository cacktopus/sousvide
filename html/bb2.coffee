M = Backbone.Model.extend {
  urlRoot: 'sousvide'

  defaults:
    temp: ''
    setpoint: ''
    id: 0
    dn_l: 0
    up_l: 0
    on: false

  refresh: ()->
    model.fetch {
      error: ()->
        console.log 'error'
    }
}

V = Backbone.View.extend {
  initialize: () ->
    me = this
    #read about this in the javascript books
    this.options.model.on 'change', (event)->
      me.render()
    this.render()


  render: () ->
    template = _.template $("#gui_template").html(), this.options.model.toJSON()

    this.$el.html template

  events:
    "click #refresh_button": "doRefresh"
    "click #setpoint": "doSetpoint"
    "click #on": "turnOn"
    "click #off": "turnOff"

  doRefresh: (event) ->
    this.options.model.refresh()

  doSetpoint: (event) ->
    set = prompt 'New setpoint'
    val = parseFloat set
    this.options.model.save {setpoint: val}

  turnOn: ->
    this.options.model.save {on: true}

  turnOff: ->
    this.options.model.save {on: false}
}

model = new M
view = new V {el: $("#gui"), model: model}

model.refresh()

setInterval model.refresh, 5000


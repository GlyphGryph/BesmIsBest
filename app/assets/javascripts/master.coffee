Eidolon = {}
this.Eidolon = Eidolon

Eidolon.Channels = {}
Eidolon.Cable = {}

class Eidolon.MasterController
  constructor: () ->
    # Do nothing

  start: () ->
    # Begin loading the page!
    @subscribe('world')

  subscribe: (name) ->
    console.log('subscribing')
    upname = name.substr(0,1).toUpperCase()+name.substr(1)
    subscriptionController = new Eidolon[upname+"Subscription"]()
    channel = upname+"Channel"
    Eidolon.Channels[name] = Eidolon.cable.subscriptions.create(channel, subscriptionController)

  state: {}

Eidolon.application = new Eidolon.MasterController()


$ ->
  Eidolon.application.start()

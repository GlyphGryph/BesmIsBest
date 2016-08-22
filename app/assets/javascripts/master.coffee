Eidolon = {}
this.Eidolon = Eidolon

Eidolon.Channels = {}
Eidolon.Cable = {}

class Eidolon.MasterController
  class: 'MasterController'
  start: () ->
    if $('body.master.begin').length > 0
      @subscribe('world')
    console.log('Watching for keypresses')
    $(document).keydown(@keypressHandler)

  subscribe: (name) ->
    console.log('Subscribing to '+name)
    upname = name.substr(0,1).toUpperCase()+name.substr(1)
    subscriptionController = new Eidolon[upname+"Subscription"]()
    channel = upname+"Channel"
    Eidolon.Channels[name] = Eidolon.cable.subscriptions.create(channel, subscriptionController)

  subscribed: () ->
    @setController(Eidolon.worldController)

  actionAllowed: false

  keypressHandler: (e) =>
    if(@actionAllowed && @currentController && @currentController.active)
      key = e.which
      console.log('Keypress seen: '+key)
      @actionAllowed = false
      captured = @receiveKey(e.which)
      if(!captured)
        captured = @currentController.receiveKey(e.which)
      if(captured)
        e.preventDefault()
      else
        @actionAllowed = true
  
  receiveKey: (key) ->
    switch(key)
      when 65
        console.log('Leaving battle...')
        Eidolon.Channels.world.perform('leave_battle')
      when 66
        console.log('Entering battle...')
        Eidolon.Channels.world.perform('enter_battle')
      else
        return false
    @actionAllowed = true
    return true
  
  enterBattle: () ->
    @setController(Eidolon.battleController)

  leaveBattle: () ->
    @setController(Eidolon.worldController)

  setController: (controller) ->
    console.log('Switching Controller to '+controller.class)
    if(@currentController)
      @currentController.end()
    @currentController = controller
    @currentController.start()

  update: (data) ->
    @currentController.update(data)

Eidolon.application = new Eidolon.MasterController()

$ ->
  Eidolon.application.start()

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
    @setController(Eidolon.worldController)
    Eidolon.Channels[name] = Eidolon.cable.subscriptions.create(channel, subscriptionController)

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
      when 65 then @setController(Eidolon.worldController)
      when 66 then @setController(Eidolon.battleController)
      else
        return false
    @actionAllowed = true
    return true


  setController: (controller) ->
    console.log('Switching Controller to '+controller.class)
    if(@currentController)
      @currentController.end()
    @currentController = controller
    @currentController.start()

Eidolon.application = new Eidolon.MasterController()

$ ->
  Eidolon.application.start()

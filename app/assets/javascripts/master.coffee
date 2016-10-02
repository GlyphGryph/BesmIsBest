Eidolon = {}
this.Eidolon = Eidolon

Eidolon.Channels = {}
Eidolon.Cable = {}

class Eidolon.MasterController
  class: 'MasterController'
  start: () ->
    @subscribe('master')

  subscribed: (data) ->
    console.log('Receiving subscription data: '+data.state)
    if(data.state.mode == 'world')
      @setController(Eidolon.worldController)
    else if(data.state.mode == 'battle')
      @setController(Eidolon.battleController)
    console.log('Watching for keypresses')
    $(document).on('keydown', @keypressHandler)

  subscribe: (name) ->
    console.log('Subscribing to '+name)
    upname = name.substr(0,1).toUpperCase()+name.substr(1)
    subscriptionController = new Eidolon[upname+"Subscription"]()
    channel = upname+"Channel"
    Eidolon.Channels[name] = Eidolon.cable.subscriptions.create(channel, subscriptionController)

  actionAllowed: false

  keypressHandler: (e) =>
    if(@actionAllowed && @currentController && @currentController.active && !@keyupKey)
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

  keyupHandler: (e) =>
    if(e.which == @keyupKey)
      console.log("Keyup of "+e.which+" detected, allowing input")
      $(document).off('keyup')
      @keyupKey = null
      @actionAllowed = true

  waitForKeyup: (key) =>
    console.log("Waiting for keyup of "+key)
    @keyupKey = key
    $(document).on('keyup', @keyupHandler)
  
  receiveKey: (key) ->
    switch(key)
      when 65
        console.log('Leaving battle...')
        Eidolon.Channels.master.perform('leave_battle')
      when 66
        console.log('Entering battle...')
        Eidolon.Channels.master.perform('enter_battle')
      else
        return false
    @actionAllowed = true
    return true
  
  enterBattle: (data) ->
    console.log('Battle data received. Loading battle!')
    @initialBattleState = data
    @actionAllowed = false
    if('#map-zone').count > 0
      $('#map-zone').fadeTo(600, 0, @finishEnteringBattle)
    else
      @finishEnteringBattle()
    
  finishEnteringBattle: () =>
    @setController(Eidolon.battleController)
    @actionAllowed = true

  leaveBattle: () ->
    @setController(Eidolon.worldController)

  setController: (controller) ->
    console.log('Switching Controller to '+controller.class)
    if(@currentController)
      @currentController.end()
    @currentController = controller
    @currentController.start()

  update: (data) ->
    if(data.mode == @currentController.mode)
      @currentController.update(data)

  updateState: (data) ->
    if(data.mode == @currentController.mode)
      @currentController.updateState(data)

  updateEvents: (data) ->
    if(data.mode == @currentController.mode)
      @currentController.updateEvents(data)

  updatePlayerList: (data) ->
    if(data.mode == @currentController.mode)
      @currentController.updatePlayerList(data)

  updateSubscription: (data) ->
    if(data.mode == @currentController.mode)
      @currentController.subscribed(data)

  battleRequested: (data) ->
     confirm_text = data['source']['name']+'has challenged you to a fight!\nDo you wish to fight now?'
     if(confirm(confirm_text))
      @acceptFight(data['source']['id'])


  acceptFight: (character_id) ->
    Eidolon.Channels.master.perform('accept_battle', {character_id: character_id})

  commandProcessed: (data={}) ->
    if(data.message?)
      console.log(data.message)
    @actionAllowed = true

Eidolon.application = new Eidolon.MasterController()

$ ->
  Eidolon.application.start()

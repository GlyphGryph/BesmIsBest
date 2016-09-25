class Eidolon.BattleController
  class: 'BattleController'
  mode: 'battle'
  menuMode: 'wait'
  active: false
  optionList: null

  start: ->
    if(Eidolon.application.initialBattleState)
      @active = true
      @eventQueue = []
      Eidolon.application.subscribe('battle')
      @loadState(Eidolon.application.initialBattleState)
    else # Data not provided, cannot start. Request data and try again
      Eidolon.Channels.master.perform('join_battle')

  end: ->
    if(Eidolon.Channels.battle)
      Eidolon.Channels.battle.unsubscribe
      Eidolon.Channels.battle = null
      Eidolon.application.initialBattleState = null

      @active = false

  loadState: (data) ->
    @state = {
      max_time_units: data.max_time_units,
      own: data.own_state,
      enemy: data.enemy_state,
      events: data.events
    }
    @setHealthPercents()
    @setTimeUnitPercents()
    console.log('Received State:')
    console.log(@state)
    # Replacing state
    $('body').html(HandlebarsTemplates.battle(@state))
    @updateEvents(data)

  updateEvents: (data)->
    events = data.events
    console.log('Received Events:')
    console.log(events)
    @menuMode = 'normal'
    if(events?)
      @eventQueue = @eventQueue.concat(events)
    @processNextEvent()

  processNextEvent: () ->
    @state.display_options = false
    if(@menuMode == 'wait')
      console.log('waiting')
      $('#battle-text').html(Handlebars.partials._battle_text(@state))
      $('#battle-text .continue-arrow').hide()
      @menuMode = 'viewText'
    else if(@eventQueue.length > 0)
      nextEvent = @eventQueue.shift()
      if(nextEvent.type == 'text')
        console.log('displaying text')
        @state.currentText = nextEvent.value
        $('#battle-text').html(Handlebars.partials._battle_text(@state))
        $('#battle-text .continue-arrow').show()
      else if(nextEvent.type == 'delay')
        console.log('delaying')
        @menuMode = 'wait'
        @state.currentText = ''
        $('#battle-text').html(Handlebars.partials._battle_text(@state))
        $('#battle-text .continue-arrow').hide()
        setTimeout(@delayCompleted,300)
      else if(nextEvent.type == 'update')
        console.log('updating')
        if( (nextEvent.stat == 'health' || nextEvent.stat == 'time_units') && nextEvent.value < 0)
          nextEvent.value = 0
        @state[nextEvent.side][nextEvent.stat] = nextEvent.value
        if(nextEvent.stat == 'health')
          @setHealthPercents()
        else if(nextEvent.stat == 'time_units')
          @setTimeUnitPercents()
        $('#battle-display').html(Handlebars.partials._battle_display(@state))
        @processNextEvent()
      else if(nextEvent.type == 'end_battle')
        @menuMode = 'wait'
        Eidolon.application.leaveBattle()
        console.log('left battle')
      else if(nextEvent.type == 'wait')
        @state.currentText = "Waiting..."
        $('#battle-text').html(Handlebars.partials._battle_text(@state))
        $('#battle-text .continue-arrow').hide()
        console.log('waiting for turn')
      else if(nextEvent.type == 'take_turn')
        console.log('taking turn')
        @state.display_options = true
        @state.options = @state.own.moves
        $('#battle-text').html(Handlebars.partials._battle_text(@state))
        $('#battle-text .continue-arrow').hide()
        @menuMode =  'list'
        @optionList = new Eidolon.OptionList($('.option-list'), @moveSelected)
      else if(nextEvent.type == 'swap')
        console.log('loading new spirit')
        @state[nextEvent.side] = nextEvent.value
        @setHealthPercents()
        @setTimeUnitPercents()
        $('#battle-display').html(Handlebars.partials._battle_display(@state))
      else
        console.log('Unrecognized event: '+nextEvent.type)
        @state.currentText = "ERROR: Unrecognized event in stack."
        $('#battle-text').html(Handlebars.partials._battle_text(@state))
        $('#battle-text .continue-arrow').show()

  delayCompleted: () =>
    console.log('resuming!')
    @menuMode = 'normal'
    @processNextEvent()

  moveSelected: (data) =>
    delete @optionList
    @foundMove = move for move in @state.own.moves when move.id is data.id
    if(@foundMove.targets.length > 0)
      @state.options = @foundMove.targets
      $('#battle-text').html(Handlebars.partials._battle_text(@state))
      @optionList = new Eidolon.OptionList($('.option-list'), @targetSelected)
    else
      @takeTurn(@foundMove.id)

  targetSelected: (data) =>
    delete @optionList
    @takeTurn(@foundMove.id, data.id)

  takeTurn: (move_id, target_id=null) ->
    @menuMode = 'wait'
    Eidolon.Channels.battle.perform('take_turn', {move_id: move_id, target_id: target_id})
    console.log('taking turn')
    @state.display_options = false
    @state.currentText = '...'
    $('#battle-text').html(Handlebars.partials._battle_text(@state))
    $('#battle-text .continue-arrow').hide()
    @menuMode = 'viewText'

  setHealthPercents: () ->
    @state.own.health_percent = 100 * @state.own.health / @state.own.max_health
    @state.enemy.health_percent = 100 * @state.enemy.health / @state.enemy.max_health

  setTimeUnitPercents: () ->
    @state.own.time_unit_percent = 100 * @state.own.time_units / @state.max_time_units
    @state.enemy.time_unit_percent = 100 * @state.enemy.time_units / @state.max_time_units

  receiveConfirmation: () ->
    switch(@menuMode)
      when 'normal'
        @processNextEvent()

  receiveKey: (key) ->
    if(@optionList?)
      return @optionList.receiveKey(key)
    switch(key)
      when 13
        @receiveConfirmation()
      else
        return false
    Eidolon.application.waitForKeyup(key)
    return true

Eidolon.battleController = new Eidolon.BattleController()

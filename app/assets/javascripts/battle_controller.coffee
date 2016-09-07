class Eidolon.BattleController
  class: 'BattleController'
  mode: 'battle'
  menuMode: 'wait'
  active: false
  indicatedMoveIndex: null
  currentText: 'Waiting...'

  start: ->
    @active = true
    @eventQueue = []
    if(Eidolon.Channels.battle)
      @subscribed()
    else
      Eidolon.application.subscribe('battle')

  end: ->
    @active = false

  subscribed: ->
    Eidolon.Channels.battle.perform('request_state')

  updateState: (data) ->
    @state = {
      max_time_units: data.max_time_units,
      own: data.own_state,
      enemy: data.enemy_state
    }
    @setHealthPercents()
    @setTimeUnitPercents()
    console.log('Received State:')
    console.log(@state)
    $('body').html(HandlebarsTemplates.battle(@state))
    @receiveEvents(data.events)

  updateEvents: (data) ->
    @receiveEvents(data.events)

  receiveEvents: (events)->
    console.log('Received Events:')
    console.log(events)
    @menuMode = 'normal'
    if(events?)
      @eventQueue = @eventQueue.concat(events)
    @processNextEvent()

  processNextEvent: () ->
    if(@menuMode == 'wait')
      console.log('waiting')
      $('#battle-text .text').text(@currentText)
      $('#battle-text .continue-arrow').hide()
      @menuMode = 'viewText'
    else if(@eventQueue.length > 0)
      nextEvent = @eventQueue.shift()
      if(nextEvent.type == 'text')
        console.log('displaying text')
        @currentText = nextEvent.value
        $('#battle-text .text').text(@currentText)
        $('#battle-text .continue-arrow').show()
      else if(nextEvent.type == 'delay')
        console.log('delaying')
        @menuMode = 'wait'
        @currentText = ''
        $('#battle-text .text').text(@currentText)
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
        $('#battle-text .continue-arrow').hide()
        @processNextEvent()
      else if(nextEvent.type == 'end_battle')
        @menuMode = 'wait'
        Eidolon.application.leaveBattle()
        console.log('left battle')
    else
      console.log('displaying move list')
      $('#battle-text .continue-arrow').hide()
      $('#battle-text .text').html(@moveListElement())
      @menuMode =  'list'
      @newMoveIndex(0)

  delayCompleted: () =>
    console.log('resuming!')
    @menuMode = 'normal'
    @processNextEvent()

  selectMove: () ->
    @menuMode = 'wait'
    Eidolon.Channels.battle.perform('action_select', {move_id: @indicatedMove().id})

  moveListElement: () ->
    element = $('<table></table>').addClass('move-list')
    for move in @state.own.moves
      moveElement = $('<tr></tr>').addClass('move').attr('data-id', move.id)
      moveSelector = $('<td></td>').addClass('indicator-cell')
      moveText = $('<td></td>').addClass('move-name-cell').text(move.name)
      moveElement.append(moveSelector).append(moveText)
      element.append(moveElement)

  indicatedMove: () ->
    @state.own.moves[@indicatedMoveIndex]

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
      when 'list'
        @selectMove()
  
  indicatorDown: () ->
    switch(@menuMode)
      when 'list'
        if(@indicatedMoveIndex < (@state.own.moves.length-1))
          @newMoveIndex(@indicatedMoveIndex + 1)

  indicatorUp: () ->
    switch(@menuMode)
      when 'list'
        if(@indicatedMoveIndex > 0)
          @newMoveIndex(@indicatedMoveIndex - 1)

  newMoveIndex: (newIndex) ->
    @indicatedMoveIndex = newIndex
    element = $('.move-list')
    element.find('.move .indicator-cell').removeClass('blink').text('')
    element.find('.move[data-id='+@indicatedMove().id+'] .indicator-cell').addClass('blink').text('>')

  receiveKey: (key) ->
    switch(key)
      when 13
        @receiveConfirmation()
        Eidolon.application.waitForKeyup(key)
      when 38
        @indicatorUp()
        Eidolon.application.waitForKeyup(key)
      when 40
        @indicatorDown()
        Eidolon.application.waitForKeyup(key)
      else
        return false
    return true

Eidolon.battleController = new Eidolon.BattleController()

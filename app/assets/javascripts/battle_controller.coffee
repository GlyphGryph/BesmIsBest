class Eidolon.BattleController
  class: 'BattleController'
  mode: 'battle'
  menuMode: 'wait'
  active: false
  indicatedMoveIndex: null
  indicatedMove: null
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
    Eidolon.Channels.battle.perform('request_update')

  update: (data) ->
    if(data.state.initial)
      @state = data.state
      @setHealthPercents()
      @setTimeUnitPercents()
      $('body').html(HandlebarsTemplates.battle(@state))
    @receiveEvents(data.state.events)

  receiveEvents: (events)->
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
        console.log('leaving battle')
        @menuMode = 'wait'
        Eidolon.Channels.world.perform('leave_battle')
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
    @currentText = @state.side_one.name+" uses "+@indicatedMove.name
    $('#battle-text .text').text(@currentText)
    $('#battle-text .continue-arrow').hide()
    @menuMode = 'wait'
    Eidolon.Channels.battle.perform('action_select', {move_id: @indicatedMove.id})

  moveListElement: () ->
    element = $('<table></table>').addClass('move-list')
    for move in @state.side_one.moves
      moveElement = $('<tr></tr>').addClass('move').attr('data-id', move.id)
      moveSelector = $('<td></td>').addClass('indicator-cell')
      moveText = $('<td></td>').addClass('move-name-cell').text(move.name)
      moveElement.append(moveSelector).append(moveText)
      element.append(moveElement)

  setHealthPercents: () ->
    @state.side_one.health_percent = 100 * @state.side_one.health / @state.side_one.max_health
    @state.side_two.health_percent = 100 * @state.side_two.health / @state.side_two.max_health

  setTimeUnitPercents: () ->
    @state.side_one.time_unit_percent = 100 * @state.side_one.time_units / @state.side_one.max_time_units
    @state.side_two.time_unit_percent = 100 * @state.side_two.time_units / @state.side_two.max_time_units

  receiveConfirmation: () ->
    switch(@menuMode)
      when 'normal'
        @processNextEvent()
      when 'list'
        @selectMove()
  
  indicatorDown: () ->
    switch(@menuMode)
      when 'list'
        if(@indicatedMoveIndex < (@state.side_one.moves.length-1))
          @newMoveIndex(@indicatedMoveIndex + 1)

  indicatorUp: () ->
    switch(@menuMode)
      when 'list'
        if(@indicatedMoveIndex > 0)
          @newMoveIndex(@indicatedMoveIndex - 1)

  newMoveIndex: (newIndex) ->
    @indicatedMoveIndex = newIndex
    @indicatedMove = @state.side_one.moves[@indicatedMoveIndex]
    element = $('.move-list')
    element.find('.move .indicator-cell').removeClass('blink').text('')
    element.find('.move[data-id='+@indicatedMove.id+'] .indicator-cell').addClass('blink').text('>')

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

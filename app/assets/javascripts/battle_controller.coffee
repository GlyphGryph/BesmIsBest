class Eidolon.BattleController
  class: 'BattleController'
  mode: 'battle'
  menuMode: 'none'
  active: false
  indicatedMoveIndex: null
  indicatedMove: null
  waitText: 'Waiting...'

  start: ->
    @active = true
    @messageQueue = []
    Eidolon.application.subscribe('battle')

  end: ->
    @active = false

  subscribed: ->
    Eidolon.Channels.battle.perform('request_update')

  update: (data) ->
    @state = data.state
    $('body').html(HandlebarsTemplates.battle(@state))
    @receiveTexts(@state.side_one.texts)

  receiveTexts: (texts)->
    if(texts?)
      @messageQueue = @messageQueue.concat(texts)
    @displayNextText()

  displayNextText: () ->
    if(@menuMode == 'wait')
      $('#battle-text .text').text(@waitText)
      $('#battle-text .continue-arrow').show()
      @menuMode = 'viewText'
    else if(@messageQueue.length > 0)
      $('#battle-text .text').text(@messageQueue.shift())
      $('#battle-text .continue-arrow').show()
      @menuMode = 'viewText'
    else
      $('#battle-text .continue-arrow').hide()
      $('#battle-text .text').html(@moveListElement())
      @menuMode =  'viewMoves'
      @newMoveIndex(0)

  selectMove: () ->
    @waitText = @state.side_one.name+" uses "+@indicatedMove.name
    $('#battle-text .text').text(@waitText)
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
    return element

  receiveConfirmation: () ->
    switch(@menuMode)
      when 'viewText'
        @displayNextText()
      when 'viewMoves'
        @selectMove()
  
  indicatorDown: () ->
    switch(@menuMode)
      when 'viewMoves'
        if(@indicatedMoveIndex < (@state.side_one.moves.length-1))
          @newMoveIndex(@indicatedMoveIndex + 1)

  indicatorUp: () ->
    switch(@menuMode)
      when 'viewMoves'
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


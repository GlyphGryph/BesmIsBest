class Eidolon.BattleController
  class: 'BattleController'
  mode: 'battle'
  active: false

  start: ->
    @active = true
    @messageQueue = []
    Eidolon.Channels.world.perform('request_update')

  end: ->
    @active = false

  update: (data) ->
    @state = data.state
    $('body').html(HandlebarsTemplates.battle(@state))
    @receiveTexts(@state.side_one.texts)

  receiveTexts: (texts)->
    if(texts? && texts.length > 0)
      @messageQueue = @messageQueue.concat(texts)
      @displayNextText()

  displayNextText: () ->
    if(@messageQueue.length > 0)
      $('#battle-text .text').text(@messageQueue.shift())
      $('#battle-text .continue-arrow').show()
    else
      $('#battle-text .continue-arrow').hide()
      $('#battle-text .text').html(@moveListElement())
  
  moveListElement: () ->
    element = $('<div></div>').addClass('move-list')
    for move in @state.side_one.moves
      moveElement = $('<div></div>').addClass('move').attr('data-id', move.id).text(move.name)
      element.append(moveElement)

  receiveKey: (key) ->
    switch(key)
      when 13
        @displayNextText()
        Eidolon.application.waitForKeyup(key)
      else
        return false
    return true

Eidolon.battleController = new Eidolon.BattleController()


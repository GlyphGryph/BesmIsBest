class Eidolon.BattleController
  class: 'BattleController'
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
      $('#battle-text .text').text("[ACTION SELECTION PLACEHOLDER]")
    
  receiveKey: (key) ->
    switch(key)
      when 13
        @displayNextText()
        Eidolon.application.waitForKeyup(key)
      else
        return false
    return true

Eidolon.battleController = new Eidolon.BattleController()


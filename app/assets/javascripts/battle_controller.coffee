class Eidolon.BattleController
  class: 'BattleController'
  active: false

  start: ->
    @active = true
    Eidolon.Channels.world.perform('request_update')

  end: ->
    @active = false

  update: (data) ->
    @state = data.state
    $('body').html(HandlebarsTemplates.battle(@state))

  receiveKey: (key) ->
    return false

Eidolon.battleController = new Eidolon.BattleController()


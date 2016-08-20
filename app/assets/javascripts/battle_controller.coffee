class Eidolon.BattleController
  class: 'BattleController'
  active: false

  start: ->
    @active = true
    @update()

  end: ->
    @active = false

  update: () ->
    console.log('Updating '+@class)
    $('body').html(HandlebarsTemplates.battle())

  receiveKey: (key) ->
    return false

Eidolon.battleController = new Eidolon.BattleController()


class Eidolon.WorldController
  class: 'WorldController'
  mode: 'world'
  map: {}
  team: []
  active: false
  menuOptions: [
    {id: 'info', name: 'Info'}
    {id: 'team', name: 'Team'}
  ]
  @activeMenu: null

  start: () ->
    @active = true
    if(Eidolon.Channels.world)
      Eidolon.Channels.world.perform('request_update')
    else
      Eidolon.application.subscribe('world')
    $('body').on('click', '.move.unequipped', @equipMove)
    $('body').on('click', '.move.equipped', @unequipMove)
    $('body').on('click', '.dismiss', @dismissSpirit)
    $('body').on('click', '.shift-up', @shiftSpiritUp)
    $('body').on('click', '.shift-down', @shiftSpiritDown)
    $('body').on('click', '.request-battle', @requestBattle)

  end: () ->
    @active = false

  update: (data) ->
    console.log(data)
    @map.rows = data.map
    @team = data.team
    @character = data.character
    @players = @processPlayers(data.players)
    for row, row_num in @map.rows
      for cell, column_num in row
        if(cell == 0)
          @map.rows[row_num][column_num] = {class: 'empty', occupied: false}
        else
          @map.rows[row_num][column_num] = {class: 'occupied', occupied: true}
    $('body').html(HandlebarsTemplates.map(@))

  updatePlayerList: (data) ->
    @players = @processPlayers(data.players)
    $('body').html(HandlebarsTemplates.map(@))

  processPlayers: (player_list) ->
    for player in player_list
      if player.id != @character.id
        player.available = true
      else
        player.available = false
    return player_list

  move: (direction) ->
    Eidolon.Channels.world.perform('move', {direction: direction})

  equipMove: (event) ->
    Eidolon.Channels.world.perform('equip_move', {move_id: $(this).data('id'), spirit_id: $(this).parents('.spirit').data('id')})

  unequipMove: (event) ->
    Eidolon.Channels.world.perform('unequip_move', {move_id: $(this).data('id'), spirit_id: $(this).parents('.spirit').data('id')})

  dismissSpirit: (event) ->
    Eidolon.Channels.world.perform('dismiss_spirit', {spirit_id: $(this).parents('.spirit').data('id')})

  shiftSpiritUp: (event) ->
    Eidolon.Channels.world.perform('shift_spirit_up', {spirit_id: $(this).parents('.spirit').data('id')})

  shiftSpiritDown: (event) ->
    Eidolon.Channels.world.perform('shift_spirit_down', {spirit_id: $(this).parents('.spirit').data('id')})

  requestBattle: (event) ->
    $('body').off('click', '.request-battle', @requestBattle)
    $('body .request-battle').remove()
    Eidolon.Channels.master.perform('request_battle', {character_id: $(this).data('id')})

  receiveKey: (key) ->
    switch(key)
      when 37 then @move('left')
      when 38 then @move('up')
      when 39 then @move('right')
      when 40 then @move('down')
      else
        return false
    return true

Eidolon.worldController = new Eidolon.WorldController()

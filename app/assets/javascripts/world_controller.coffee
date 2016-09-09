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
      @subscribed()
    else
      Eidolon.application.subscribe('world')

  subscribed: ->
    Eidolon.Channels.world.perform('request_update')

  end: () ->
    @active = false

  update: (data) ->
    console.log(data)
    @map.rows = data.map
    @team = data.team
    for row, row_num in @map.rows
      for cell, column_num in row
        if(cell == 0)
          @map.rows[row_num][column_num] = {class: 'empty', occupied: false}
        else
          @map.rows[row_num][column_num] = {class: 'occupied', occupied: true}
    $('body').html(HandlebarsTemplates.map(@))

  move: (direction) ->
    Eidolon.Channels.world.perform('move', {direction: direction})

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

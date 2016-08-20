Eidolon = {}
this.Eidolon = Eidolon

Eidolon.Channels = {}
Eidolon.Cable = {}

class Eidolon.MasterController
  constructor: () ->
    # Do nothing

  start: () ->
    if $('body.master.begin').length > 0
      @subscribe('world')

  subscribe: (name) ->
    console.log('Subscribing to '+name)
    upname = name.substr(0,1).toUpperCase()+name.substr(1)
    subscriptionController = new Eidolon[upname+"Subscription"]()
    channel = upname+"Channel"
    Eidolon.Channels[name] = Eidolon.cable.subscriptions.create(channel, subscriptionController)

  map: {}

  worldStarted: false
  actionAllowed: false

  startWorld: () ->
    @worldStarted =  true
    @actionAllowed = true
    console.log('Watching for keypresses')
    $(document).keydown(@keypressHandler)

  updateWorld: () ->
    for row, row_num in @map.rows
      for cell, column_num in row
        if(cell == 0)
          @map.rows[row_num][column_num] = {class: 'empty', occupied: false}
        else
          @map.rows[row_num][column_num] = {class: 'occupied', occupied: true}
    $('body').html(HandlebarsTemplates['map'](@map))
    if(!@worldStarted)
      @startWorld()
  
  move: (direction) ->
    console.log('Moving '+direction)
    Eidolon.Channels.world.perform('move', {direction: direction})
  
  keypressHandler: (e) =>
    if(@actionAllowed)
      console.log('Keypress seen: '+e.which)
      @actionAllowed = false
      switch(e.which)
        when 37 then @move('left')
        when 38 then @move('up')
        when 39 then @move('right')
        when 40 then @move('down')
        else
          @actionAllowed = true
          return # Prevents prevention of default
      e.preventDefault()

Eidolon.application = new Eidolon.MasterController()

$ ->
  Eidolon.application.start()

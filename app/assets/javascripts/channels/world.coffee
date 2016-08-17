class Eidolon.WorldSubscription
  connected: ->
    @app = Eidolon.application
    # Do nothing

  received: (data) ->
    @[data.action](data)

  ping: (data) ->
    alert('ping!')

  mapState: (data) ->
    console.log('loading map state')
    @app.state.rows = data.state
    for row, row_num in @app.state.rows
      for cell, column_num in row
        if(cell == 0)
          @app.state.rows[row_num][column_num] = {class: 'empty', occupied: false}
        else
          @app.state.rows[row_num][column_num] = {class: 'occupied', occupied: true}
    $('body').html(HandlebarsTemplates['map'](@app.state))

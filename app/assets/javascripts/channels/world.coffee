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
    $('body').html(HandlebarsTemplates['map'](@app.state))

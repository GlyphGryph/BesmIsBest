class Eidolon.WorldSubscription
  connected: ->
    console.log('Connecting to WorldChannel')
    @app = Eidolon.application
    # Do nothing

  received: (data) ->
    console.log('Receiving action '+data.action+', via WorldChannel')
    @[data.action](data)

  ping: (data) ->
    alert('ping!')

  mapState: (data) ->
    @app.map.rows = data.map
    @app.updateWorld()

  commandProcessed: () ->
    @app.actionAllowed = true

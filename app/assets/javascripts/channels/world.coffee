class Eidolon.WorldSubscription
  connected: ->
    console.log('Connecting to WorldChannel')
    @app = Eidolon.application

  received: (data) ->
    console.log('Receiving action '+data.action+', via WorldChannel')
    @[data.action](data)

  ping: (data) ->
    console.log('ping!')

  updateWorldMap: (data) ->
    @commandProcessed()
    if(Eidolon.worldController.active)
      Eidolon.worldController.map.rows = data.map
      Eidolon.worldController.update()

  commandProcessed: () ->
    @app.actionAllowed = true

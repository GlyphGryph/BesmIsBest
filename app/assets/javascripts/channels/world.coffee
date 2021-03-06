class Eidolon.WorldSubscription
  connected: ->
    console.log('Connecting to WorldChannel')
    @app = Eidolon.application

  received: (data) ->
    console.log('Receiving action '+data.action+', via WorldChannel')
    @[data.action](data)

  update: (data) ->
    @app.update(data)
    @app.commandProcessed()

  updatePlayerList: (data) ->
    @app.updatePlayerList(data)

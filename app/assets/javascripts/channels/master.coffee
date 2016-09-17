class Eidolon.MasterSubscription
  connected: ->
    console.log('Connecting to MasterChannel')
    @app = Eidolon.application

  received: (data) ->
    console.log('Receiving action '+data.action+', via MasterChannel')
    @[data.action](data)

  subscribed: (data) ->
    @app.subscribed(data)

  commandProcessed: (data) ->
    @app.commandProcessed(data)

  joinedBattle: (data) ->
    @app.enterBattle(data)
    @commandProcessed()

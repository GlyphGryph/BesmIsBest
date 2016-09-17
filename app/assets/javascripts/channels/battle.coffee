class Eidolon.BattleSubscription
  connected: ->
    console.log('Connecting to BattleChannel')
    @app = Eidolon.application

  received: (data) ->
    console.log('Receiving action '+data.action+', via BattleChannel')
    @[data.action](data)

  subscribed: (data) ->
    @app.updateSubscription(data)

  updateEvents: (data) ->
    @app.updateEvents(data)
    @app.commandProcessed()

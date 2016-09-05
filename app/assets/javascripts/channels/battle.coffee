class Eidolon.BattleSubscription
  connected: ->
    console.log('Connecting to BattleChannel')
    @app = Eidolon.application

  received: (data) ->
    console.log('Receiving action '+data.action+', via BattleChannel')
    @[data.action](data)

  ping: (data) ->
    console.log('ping!')

  subscribed: () ->
    @app.subscribed()

  updateState: (data) ->
    @app.updateState(data)
    @commandProcessed()

  updateEvents: (data) ->
    @app.updateEvents(data)
    @commandProcessed()

  leaveBattle: (data) ->
    @app.leaveBattle()
    @commandProcessed()

  commandProcessed: (data={}) ->
    if(data.message?)
      console.log(data.message)
    @app.actionAllowed = true

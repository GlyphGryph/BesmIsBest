class Eidolon.WorldSubscription
  connected: ->
    console.log('Connecting to WorldChannel')
    @app = Eidolon.application

  received: (data) ->
    console.log('Receiving action '+data.action+', via WorldChannel')
    @[data.action](data)

  ping: (data) ->
    console.log('ping!')

  subscribed: () ->
    @app.subscribed()

  update: (data) ->
    @app.update(data)
    @commandProcessed()

  enterBattle: (data) ->
    @app.enterBattle()
    @commandProcessed()

  leaveBattle: (data) ->
    @app.leaveBattle()
    @commandProcessed()

  commandProcessed: (data={}) ->
    if(data.message?)
      console.log(data.message)
    @app.actionAllowed = true

Eidolon.Channels.world = Eidolon.cable.subscriptions.create "WorldChannel",
  connected: ->
    # Do nothing

  received: (data) ->
    @[data.action](data)

  ping: (data) ->
    alert('ping!')

Eidolon = {}
this.Eidolon = Eidolon

Eidolon.Channels = {}
Eidolon.Classes = {}
Eidolon.Application = {}
Eidolon.Cable = {}

Eidolon.Classes.MasterController = class
  constructor: (@websocket) ->
    @test = 'yeah!'
    alert('whoo')

Eidolon.application = new Eidolon.Classes.MasterController()

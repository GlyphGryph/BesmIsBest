class Eidolon.OptionList
  class: 'OptionList'

  constructor: (@optionListElement, @callback) ->
    @optionElements = @optionListElement.find('.option')
    @markedIndex = 0
    @updateDisplay()

  confirm: ->
    @callback(@getMarkedOption().data())
    
  up: ->
    if(@markedIndex > 0)
      @markedIndex -= 1
      @updateDisplay()

  down: ->

    if(@markedIndex + 1 < @optionElements.length)
      @markedIndex += 1
      @updateDisplay()

  getMarkedOption: ->
    $(@optionElements[@markedIndex])

  updateDisplay: ->
    @optionElements.find('.indicator-cell').removeClass('blink').text('')
    @getMarkedOption().find('.indicator-cell').addClass('blink').text('>')

  receiveKey: (key) ->
    switch(key)
      when 13
        @confirm()
      when 38
        @up()
      when 40
        @down()
      else
        return false
    Eidolon.application.waitForKeyup(key)
    return true

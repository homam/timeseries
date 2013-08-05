define [], () ->
  class Property
    constructor: (@_onSet) ->
      _value: null
    set: (value)->
      this._value = value
      this._onSet(value)
    get: () ->
      this._value
    reset: () ->
      this.set(this._value)

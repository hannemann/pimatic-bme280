module.exports = (env) ->
  Promise = env.require 'bluebird'

  declapi = env.require 'decl-api'
  t = declapi.types

  class BMP280Plugin extends env.plugins.Plugin
    init: (app, @framework, @config) =>
      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("BMP280Sensor", {
        configDef: deviceConfigDef.BMP280Sensor,
        createCallback:(config, lastState) =>
          device = new BME280Sensor(config, lastState)
          return device
      })


  class PressureSensor extends env.devices.Sensor
    attributes:
      pressure:
        description: "Barometric pressure"
        type: t.number
        unit: 'hPa'
        acronym: 'ATM'
      temperature:
        description: "Temperature"
        type: t.number
        unit: '°C'
        acronym: 'T'

    template: "temperature"   


  class BMP280Sensor extends PressureSensor
    _pressure: null
    _temperature: null

    constructor: (@config, lastState) ->
      @id = @config.id
      @name = @config.name
      @_pressure = lastState?.pressure?.value
      @_temperature = lastState?.temperature?.value

      BME280 = require 'bme280-sensor'
      @sensor = new BME280({
        address: parseInt @config.address
      });

      Promise.promisifyAll(@sensor)

      super()

      @requestValue()
      @requestValueIntervalId = setInterval( ( => @requestValue() ), @config.interval)
    
    destroy: () ->
      clearInterval @requestValueIntervalId if @requestValueIntervalId?
      super()

    requestValue: ->
      @sensor.readSensorData().then (data) =>
        if data.pressure_hPa != @_pressure@_pressure
          @_pressure = data.pressure_hPa
          @emit 'pressure', pressure/100
      
        if data.temperature_C != @_temperature
          @_temperature = data.temperature_C
          @emit 'temperature', temperature
    )
    getPressure: -> Promise.resolve(@_pressure)
    getTemperature: -> Promise.resolve(@_temperature)

  myPlugin = new BMP280Plugin
  return myPlugin

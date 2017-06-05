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
          device = new BMP280Sensor(config, lastState)
          return device
      })


  class PressureSensor extends env.devices.Sensor

    attributes:
      pressure:
        description: "The measured barometric pressure"
        type: "number"
        unit: 'hPa'
        acronym: 'ATM'
      temperature:
        description: "The measured temperature"
        type: "number"
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
        i2cAddress: parseInt @config.address
      });

      Promise.promisifyAll(@sensor)

      super()

      @sensor.init().then @startInterval.bind(this), (err) => env.logger.debug "bmp280 initialization failed #{err}"

    startInterval: () ->
      env.logger.debug "bmp280 initialized"
      @requestValue()
      @requestValueIntervalId = setInterval( @requestValue.bind(this), @config.interval)
    
    destroy: () ->
      clearInterval @requestValueIntervalId if @requestValueIntervalId?
      super()

    requestValue: ->
      env.logger.debug "Reading from bmp280"
      @sensor.readSensorData().then( (data) ->
        env.logger.debug data
        if data.pressure_hPa != @_pressure
          @_pressure = data.pressure_hPa
          env.logger.debug @_pressure
          @emit 'pressure', data.pressure_hPa
      
        if data.temperature_C != @_temperature
          @_temperature = data.temperature_C
          @emit 'temperature', data.temperature_C
      )

    getPressure: () -> 
      env.logger.debug("Pressure: ", @_pressure)
      Promise.resolve(@_pressure)

    getTemperature: () ->
      env.logger.debug("Temp: ", @_temperature)
      Promise.resolve(@_temperature)

  myPlugin = new BMP280Plugin
  return myPlugin

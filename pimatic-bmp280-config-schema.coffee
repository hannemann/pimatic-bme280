#pimatic-bme280 configuration options
module.exports = {
  title: "pimatic-bmp280 config"
  type: "object"
  properties: {
    debug:
      description: "Debug mode"
      type: "boolean"
      default: false
  }
}

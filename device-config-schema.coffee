#pimatic-bmp280 configuration options
module.exports = {
  title: "pimatic-bmp280 config"
  BMP280Sensor: {
    title: "BMP280Sensor config options"
    type: "object"
    extensions: ["xLink","xAttributeOptions"]
    properties: {
      device:
        description: "Device file to use; default /dev/i2c-1"
        type: "string"
        default: "i2c-1"
      address:
        description: "Address to use; default 0x76"
        type: "string"
        default: "0x76"
      interval:
        description: "Interval in ms"
        type: "integer"
        default: "10000"
    }
  }
}

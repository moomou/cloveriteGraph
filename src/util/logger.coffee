_und    = require 'underscore'
winston = require 'winston'

config  = require '../config'

logger = new (winston.Logger)({
    levels: config.Winston.customLevels
    transports: [
        new (winston.transports.Console)(level: config.Winston.logLevel)
        new (winston.transports.File)(filename: config.Winston.logFile)
    ]
})

_und.extend exports, logger

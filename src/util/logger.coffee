config = require '../config'
Log    = require 'log'

exports.logger = new Log config.log.level

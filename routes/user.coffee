#entity.coffee
#Routes to CRUD entities
_und = require('underscore')
rest = require('restler')
Logger = require('util')

Neo = require('../models/neo')

Entity = require('../models/entity')
Attribute = require('../models/attribute')
Tag = require('../models/tag')

Vote = require('../models/vote')
Link = require('../models/link')

StdSchema = require('../models/stdSchema')

Constants = StdSchema.Constants
Response = StdSchema

Utility = require('./utility')

exports.getCreated = (req, res, next) ->

exports.getVoted = (req, res, next) ->

exports.getCommented = (req, res, next) ->

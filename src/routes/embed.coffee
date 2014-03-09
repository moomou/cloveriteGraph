# Cotent.coffee
#
# This is the route responsible for embedded content when
# provided with a content id (entity title + attribute/data title).
#
# Either serves a json response or serving the content with embeddable
# js for rendering.

_und            = require('underscore')
redis           = require('../models/setup').db.redis

Logger          = require 'util'
Remote          = require '../remote/remote'

Neo             = require '../models/neo'

User            = require '../models/user'
Entity          = require '../models/entity'
Attribute       = require '../models/attribute'
Data            = require '../models/data'
Tag             = require '../models/tag'

Vote            = require '../models/vote'
Link            = require '../models/link'

Constants       = require('../config').Constants

EntityUtil      = require './entity/util'

DataRoute       = require './data'

Cypher          = require './util/cypher'
CypherBuilder   = Cypher.CypherBuilder
CypherLinkUtil  = Cypher.CypherLinkUtil

Response        = require './util/response'
ErrorDevMessage = Response.ErrorDevMessage

Permission      = require './permission'

_show = (req, res, next) ->
    entityId = req.query.entity
    data     = req.query.data
    Response.OKResponse(res)(200)

exports.show = _show

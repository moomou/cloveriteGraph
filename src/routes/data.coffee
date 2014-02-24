# Data.coffee
#
#

require('source-map-support').install()

_und = require('underscore')

Neo             = require '../models/neo'
Data            = require '../models/data'
Tag             = require '../models/tag'

Constants       = require('../config').Constants

Response        = require './util/response'
ErrorDevMessage = Response.ErrorDevMessage

# GET /data/:id
exports.show = (req, res, next) ->
    if isNaN req.params.id
        return Response.ErrorResponse(res)(400, ErrorDevMessage.missingParam('id'))

    await Data.get req.params.id, defer(err, data)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    Response.OKResponse(res)(200, data.serialize())

#composed.coffee
#Routes to CRUD entities

require('source-map-support').install()
_und = require('underscore')

Neo = require('../models/neo')
Composed = require('../models/composed')
Tag = require('../models/tag')

SchemaUtil = require('../models/stdSchema')
Constants = SchemaUtil.Constants

Response = require('./response')
ErrorDevMessage = Response.ErrorDevMessage

# GET /content/:id
_show = (req, res, next) ->
    await Composed.show req.params.id, defer(err, composed)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    Response.OKResponse(res)(200, composed)

exports.show = _show

# POST /content/
_create = (req, res, next) ->
    await Composed.create req.body, defer(err, composed)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    Response.OKResponse(res)(200, composed)

exports.create = _create

# PUT /content/:id
_update = (req, res, next) ->
    await Composed.update req.params.id, req.body, defer(err, composed)

    if err
        return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err.dbError
        return Response.ErrorResponse(res)(400, err.validationError) if err.validationError

    Response.OKResponse(res)(200, composed)

exports.update = _update

# DEL /content/:id
_del = (req, res, next) ->
    await Composed.delete req.params.id, defer(err, _)

    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err
    Response.OKResponse(res)(204)

exports.del = _del

exports.getRelated = (req, res, next) ->
    res.status(503).json error: "Not Implemented"

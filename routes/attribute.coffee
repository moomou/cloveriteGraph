#attribute.coffee
#Routes to CRUD entities
require('source-map-support').install()
_und = require('underscore')

Neo = require('../models/neo')
Entity = require('../models/entity')
Attribute = require('../models/attribute')
Tag = require('../models/tag')

SchemaUtil = require('../models/stdSchema')
Constants = SchemaUtil.Constants

Response = require('./response')
ErrorDevMessage = Response.ErrorDevMessage

# GET /attribute/search/
exports.search = (req, res, next) ->
    res.redirect "/#{Constants.API_VERSION}/search/?q=#{req.query['q']}"

# POST /attribute
exports.create = (req, res, next) ->
    await Attribute.create req.body, defer(err, attr)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    await attr.serialize defer(blob)
    Response.OKResponse(res)(200, blob)

# GET /attribute/:id
exports.show = (req, res, next) ->
    if isNaN req.params.id
        return Response.ErrorResponse(res)(400, ErrorDevMessage.missingParam('id'))

    await Attribute.get req.params.id, defer(err, attr)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    entityId = req.query['entityId'] ? null

    await attr.serialize(defer(blob), entityId)
    Response.OKResponse(res)(200, blob)

# PUT /attribute/:id
exports.edit = (req, res, next) ->
    await Attribute.put req.params.id, req.body, defer(err, attr)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    await attr.serialize defer(blob)
    Response.OKResponse(res)(200, blob)

# DELETE /attribute/:id
exports.del = (req, res, next) ->
    await Attribute.get req.params.id, defer(err, attr)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    await attr.del defer(err)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    Response.OKResponse(res)(204)

# POST /attribute/:id/:relation
###
    Connect another attribute to current one using [relation]
    DATA : {
        action: add/rm
        other: attributeId,
    }
###

# GET /attribute/:id/:relation
###
    List all attribute related to this attribute through [relation]
###

#GET /attribute/:id/entity
exports.listEntity = (req, res, next) ->
    await Attribute.get req.params.id, defer(err, attr)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    await #check direction field
        attr._node.getRelationshipNodes {type: Constants.REL_ATTRIBUTE, direction:'out'},
            defer(err, nodes)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    blobs = []
    await
        for node, ind in nodes
            (new Entity node).serialize defer(blobs[ind])

    Response.OKResponse(res)(204, blob for blob in blobs)

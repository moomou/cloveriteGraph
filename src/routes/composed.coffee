# Composed.coffee
#
# This route is responsible for combining attribute and entity 
# together. 

require('source-map-support').install()
_und = require('underscore')

Neo        = require('../models/neo')
Entity     = require('../models/entity')
Composed   = require('../models/composed')
Tag        = require('../models/tag')
Link       = require('../models/link')
Constants  = require('../config').Constants

Cypher         = require './util/cypher'
CypherBuilder  = Cypher.CypherBuilder
CypherLinkUtil = Cypher.CypherLinkUtil

Response        = require './util/response'
ErrorDevMessage = Response.ErrorDevMessage

# POST /content/
_create = (req, res, next) ->
    await Composed.create req.body, defer(err, composed)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    errs       = []
    tagObjs    = []
    entityObjs = []

    await
        for tagName, ind in composed.serialize().tags
            console.log tagName
            Tag.getOrCreate tagName, defer(errs[ind], tagObjs[ind])
        for entityId, ind in composed.serialize().entityId
            console.log entityId
            Entity.get entityId, defer(_, entityObjs[ind])

    err = _und.find(errs, (err) -> err) or err
    return next(err) if err

    linkData = Link.fillMetaData({})
    for tagObj, ind in tagObjs
        await
            CypherLinkUtil.hasLink tagObj._node,
                composed._node,
                Constants.REL_ATTRIBUTE,
                "all",
                defer err, pathExists

        if not pathExists
            CypherLinkUtil.createLink tagObj._node,
                composed._node,
                Constants.REL_TAG,
                linkData,
                (err, rel) ->

    for entityObj, ind in entityObjs
        CypherLinkUtil.createLink entityObj._node, composed._node,
            Constants.REL_CONTAINER,
            {},
            (err, rel) ->

    Response.OKResponse(res)(200, composed.serialize())

exports.create = _create

# GET /content/:id
_show = (req, res, next) ->
    await Composed.get req.params.id, defer(err, composed)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err
    Response.OKResponse(res)(200, composed.serialize())

exports.show = _show

# PUT /content/:id
_update = (req, res, next) ->
    await Composed.update req.params.id, req.body, defer(err, composed)

    if err
        return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err.dbError
        return Response.ErrorResponse(res)(400, err.validationError) if err.validationError

    Response.OKResponse(res)(200, composed.serialize())

exports.update = _update

# DEL /content/:id
_del = (req, res, next) ->
    await Composed.delete req.params.id, defer(err, _)

    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err
    Response.OKResponse(res)(204)

exports.del = _del

exports.getRelated = (req, res, next) ->
    res.status(503).json error: "Not Implemented"

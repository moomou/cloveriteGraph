# entity.coffee
#
# Routes to CRUD entities

_und            = require('underscore')
redis           = require('../models/setup').db.redis

Logger          = require '../util/logger'
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
Slug            = require '../util/slug'
NumUtil         = require '../util/numUtil'

EntityUtil      = require './entity/util'

DataRoute       = require './data'

Cypher          = require './util/cypher'
CypherBuilder   = Cypher.CypherBuilder
CypherLinkUtil  = Cypher.CypherLinkUtil

Response        = require './util/response'
ErrorDevMessage = Response.ErrorDevMessage

Permission      = require './permission'

getDiscussionId = (entityId) ->
    "entity:#{entityId}:discussion"

getRelationId = (path) ->
    splits = path.relationships[0]._data.self.split('/')
    splits[splits.length - 1]

hasPermission = (req, res, next, cb) ->
    ErrorResponse = Response.ErrorResponse(res)
    await Slug.resolveSlug req.params.id, defer(err, resolvedId)

    if not NumUtil.isNum resolvedId
        return cb true, ErrorResponse(400, ErrorDevMessage.dataValidationIssue("id")), null

    await
        Entity.get resolvedId, defer(errEntity, entity)
        Permission.getUser req, defer(errUser, user)

    err = errUser or errEntity
    return cb true, ErrorResponse(500, ErrorDevMessage.dbIssue()), null if err

    req = _und.extend _und.clone(req), resolvedId: resolvedId

    # Return authorized if not private and user is anonymous
    return cb false, null, req if not entity._node.data.private and not user

    await Permission.hasPermission user, entity, defer(err, authorized)
    return cb true, ErrorResponse(500, ErrorDevMessage.dbIssue()), null if err

    if not authorized
        return cb true, ErrorResponse(401, ErrorDevMessage.permissionIssue()), null

    # Returns a new shallow copy of req with user if authenticated
    reqWithUser = _und.extend _und.clone(req),
        user: user

    return cb false, null, reqWithUser

basicAuthentication = Permission.authCurry hasPermission

# GET /entity/search/
exports.search = (req, res, next) ->
    Search = require('./search')
    Search.searchHandler req, res, next

# POST /entity - Please note, permission NOT required
exports.create = (req, res, next) ->
    await Permission.getUser req, defer(err, user)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    Logger.debug "Creating Entity"

    reqBody         = _und.clone req.body
    reqBody.user    = user
    reqBody.private = false if not user

    reqBody.tags = _und.filter reqBody.tags,
        (tag) -> tag and _und.isString(tag)

    reqBody.tags.push Constants.TAG_GLOBAL

    errs        = []
    tagObjs     = []

    await
        Entity.create reqBody, defer err, entity
        for tagName, ind in reqBody.tags
            Tag.getOrCreate tagName, defer errs[ind], tagObjs[ind]

    err = err or _und.find(errs, (err) -> err)
    return next(err) if err

    linkData = Link.fillMetaData {}

    # link user
    if user
        Logger.debug "User logged !"
        await CypherLinkUtil.createMultipleLinks user._node,
            entity._node,
            [Constants.REL_CREATED, Constants.REL_ACCESS, Constants.REL_MODIFIED],
            linkData,
            defer(err, rels)

    # "tag" entity
    for tagObj, ind in tagObjs
        Logger.debug "User logged !"
        CypherLinkUtil.createLink tagObj._node, entity._node,
            Constants.REL_TAG,
            linkData,
            (err, rel) ->

        if user
            CypherLinkUtil.createLink user._node, tagObj._node,
                Constants.REL_TAG,
                linkData,
                (err, rel) ->

    # if contains content section, add those here
    if req.body.content
        await EntityUtil.addData entity, req.body.content, defer errs, datas

    Response.OKResponse(res)(201, entity.serialize())

# GET /entity/:id
_show = (req, res, next) ->
    await Entity.get req.resolvedId, defer err, entity
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    attrBlobs = null
    dataBlobs = null

    await
        if req.query.attribute != "false"
            EntityUtil.getEntityAttributes entity, defer(attrBlobs)
        if req.query.data != "false"
            EntityUtil.getEntityData entity, defer(dataBlobs)

    entityBlob = entity.serialize null,
        attributes: attrBlobs
        data: dataBlobs

    Response.OKResponse(res)(200, entityBlob)

exports.show = basicAuthentication _show

# PUT /entity/:id
_edit = (req, res, next) ->
    req.body.user = req.user
    await Entity.put req.resolvedId, req.body, defer(err, entity)

    if err
        return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err.dbError
        return Response.ErrorResponse(res)(400, err.validationError) if err.validationError

    errs = []
    tagObjs = []

    await
        for tagName, ind in entity.serialize().tags
            Tag.getOrCreate tagName, defer(errs[ind], tagObjs[ind])

    err = _und.find(errs, (err) -> err)
    return next(err) if err

    linkData = Link.fillMetaData({})

    # "tag" entity
    for tagObj, ind in tagObjs
        await
            CypherLinkUtil.hasLink tagObj._node,
                entity._node,
                Constants.REL_ATTRIBUTE,
                "all",
                defer(err, pathExists)

        if not pathExists
            CypherLinkUtil.createLink tagObj._node,
                entity._node,
                Constants.REL_TAG,
                linkData,
                (err, rel) ->

    await entity.serialize defer blob
    Response.OKResponse(res)(200, blob)

exports.edit = basicAuthentication _edit

# DELETE /entity/:id
_del = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    await entity.del defer(err)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    Response.OKResponse(res)(204)

exports.del = basicAuthentication _del

###
# Entity Use Section
###

# GET /entity/:id/user
_showUsers = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    await
        entity._node.getRelationshipNodes [
            {type: Constants.REL_VOTED, direction: "in"},
            {type:Constants.REL_MODIFIED, direction: "in"},
            {type:Constants.REL_CREATED, direction: "in"}],
            defer(err, nodes)

    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    blobs = []
    for node, ind in nodes
        blobs[ind] = (new User node).serialize()

    Response.OKResponse(res)(200, blobs)

exports.showUsers = basicAuthentication _showUsers

# GET /entity/:id/user/:username
_showUserVoteDetail = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    await entity.getVoteByUser req.user, defer(err, blobs)
    Response.OKResponse(res)(200, blobs)

exports.showUserVoteDetail = basicAuthentication _showUserVoteDetail

###
# Entity Attribute Section
###

# GET /entity/:id/attribute
_listAttribute = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    await EntityUtil.getEntityAttributes entity, defer(blobs)
    Response.OKResponse(res)(200, blobs)

exports.listAttribute = basicAuthentication _listAttribute

# POST /entity/:id/attribute
_addAttribute = (req, res, next) ->
    valid = Attribute.validateSchema req.body

    if not valid #TODO add message / update validation
        return Response.ErrorResponse(res)(400, ErrorDevMessage.dataValidationIssue())

    # Clean Data
    data = _und.clone req.body
    delete data['id']

    # Retrieve the 2 entities
    await
        Entity.get req.params.id, defer(errE, entity)
        Attribute.getOrCreate data, defer(errA, attr)

    err = errE or errA
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    linkData = Link.normalizeData _und.clone(req.body || {})
    linkData['startend'] = EntityUtil.getStartEndIndex(
        attr._node.id,
        Constants.REL_ATTRIBUTE,
        req.params.id
    )

    Logger.debug "New Link Data: #{linkData}"

    # hasLink returns the link if it exists
    await CypherLinkUtil.hasLink entity._node,
        attr._node,
        Constants.REL_ATTRIBUTE,
        "all",
        defer(err, path)

    # If Path already exists
    if path
        relId = getRelationId path

        await
            Link.get relId, defer(err, link)

        existingLinkData = link.serialize()

        Logger.debug "EXISTING linkdata:  #{existingLinkData}"

        linkData = _und.extend existingLinkData, linkData

        Logger.debug "MERGED linkdata: #{linkData}"

        Link.put relId, linkData, ->
        rel = path.relationships[0]
    else
        linkData = Link.fillMetaData(linkData)
        await CypherLinkUtil.createLink attr._node,
            entity._node,
            Constants.REL_ATTRIBUTE,
            linkData,
            defer(err, rel)

        return next(err) if err

    Link.index rel, linkData

    await attr.serialize defer blob
    _und.extend blob, linkData: linkData
    Response.OKResponse(res)(200, blob)

exports.addAttribute = basicAuthentication _addAttribute

# DELETE /entity/:id/attribute/:aId
# by marking the link as disabled
_delAttribute = (req, res, next) ->
    await
        Entity.get req.params.id, defer(errE, entity)
        Attribute.get req.params.aId, defer(errA, attr)

    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if errA or errE

    startendVal = EntityUtil.getStartEndIndex(attr._node.id,
        Constants.REL_ATTRIBUTE,
        entity._node.id)

    await Link.find('startend', startendVal, defer(err, link))

    link._node.data.disabled = true
    link.save()
    Response.OKResponse(res)(204)

exports.delAttribute = basicAuthentication _delAttribute

#GET /entity/:id/attribute/:id
_getAttribute =(req, res, next) ->
    ErrorResponse = Response.ErrorResponse(res)

    entityId = req.params.id
    attrId = req.params.aId

    return ErrorResponse(400, ErrorDevMessage.missingParam("id")) if not attrId?

    startendVal = EntityUtil.getStartEndIndex(attrId,
        Constants.REL_ATTRIBUTE,
        entityId
    )

    await
        Link.find('startend', startendVal, defer(errLink, rel))
        Attribute.get attrId, defer(errAttr, attr)

    return ErrorResponse(500, ErrorDevMessage.dbIssue()) if errLink || errAttr

    blob = {}
    await attr.serialize(defer(blob), entityId)

    _und.extend(blob, linkData: rel.serialize())
    Response.OKResponse(res)(200, blob)

exports.getAttribute = basicAuthentication _getAttribute

#PUT /entity/:id/attribute/:id
_updateAttributeLink = (req, res, next) ->
    ErrorResponse = Response.ErrorResponse(res)

    entityId = req.params.id
    attrId = req.params.aId
    linkData = _und.clone(req.body['linkData'] || {})

    return ErrorResponse(400, ErrorDevMessage.missingParam("id")) if not attrId

    await
        Attribute.get attrId, defer(errAttr, attr)
        Link.put(linkData['id'], linkData, defer(errLink, rel))

    err = errAttr || errLink
    return ErrorResponse(500, ErrorDevMessage.dbIssue()) if err

    blob = attr.serialize()
    _und.extend blob, linkData: rel.serialize()

    Response.OKResponse(res)(200, blob)

exports.updateAttributeLink = basicAuthentication _updateAttributeLink

# POST /entity/:id/attribute/:id/vote
exports.voteAttribute = (req, res, next) ->
    await
        Entity.get req.params.id, defer(errE, entity)
        Attribute.get req.params.aId, defer(errA, attr)
        Permission.getUser req, defer(errUser, user)

    err = errA or errE
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    voteData = _und.clone req.body
    voteData.ipAddr = req.header['x-real-ip'] or req.connection.remoteAddress
    voteData.browser = req.useragent.Browser
    voteData.os = req.useragent.OS
    voteData.lang = req.headers['accept-language']
    voteData.attrId = attr.serialize().id
    voteData.attrName = attr.serialize().name
    voteData.user = user._node.data.username if user

    vote = new Vote voteData

    entity.vote user, attr, vote, (err, voteTally) ->
        return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err
        Response.OKResponse(res)(200, voteTally)

###
# Entity Data Section
###
_addData = (req, res, next) ->
    console.log ">X_X<"
    console.log ">X_X<"
    await Entity.get req.params.id, defer err, entity
    console.log ">X_X<"
    console.log err
    console.log ">X_X<"

    #return errResponse if err

    dataInput = [req.body]

    EntityUtil.addData entity, dataInput, (errs, datas) ->
        data = datas[0]

        if not errs
            Response.OKResponse(res)(200, data.serialize())
        else
            Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue())
            errResponse

exports.addData = basicAuthentication _addData

_getData = (req, res, next) ->
    req.params.id = req.params.dId
    DataRoute.show req, res, next

exports.getData = basicAuthentication _getData

_listData = (req, res, next) ->
    await
        Entity.get req.params.id, defer err, entity

    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    await EntityUtil.getEntityData entity, defer(blobs)
    Response.OKResponse(res)(200, blobs)

exports.listData = basicAuthentication _listData

_delData = (req, res, next) ->

exports.delData = basicAuthentication _delData

###
# Entity Relation section
###

# TODO Fix permission here!
# GET /entity/:id/relation
exports.listRelation = (req, res, next) ->
    entityId = req.params.id
    relType = req.params.relation

    query = CypherBuilder.getOutgoingRelsCypherQuery(entityId, relType)

    await Neo.query Link, query, {}, defer(err, rels)

    blobs = []
    await
        for rel, ind in rels
            rel = new Link rel.r

            tmp = rel._node._data.start.split('/')
            startId = tmp[tmp.length - 1]

            tmp = rel._node._data.end.split('/')
            endId = tmp[tmp.length - 1]

            extraData = {
                type: rel._node._data.type,
                start: startId
                end: endId
            }

            rel.serialize defer(blobs[ind]), extraData

    res.json(blob for blob in blobs)

# TODO Fix permission here!
# POST /entity/:id/relation/entity/:id
exports.linkEntity = (req, res, next) ->
    await
        Entity.get req.params.srcId, defer(errSrc, srcEntity)
        Entity.get req.params.dstId, defer(errDst, dstEntity)

    return next(errSrc) if errSrc
    return next(errDst) if errDst

    relation = req.body

    if relation['src_dst']
        linkName  = Link.normalizeName(relation['src_dst']['name'])
        linkData = Link.deserialize(relation['src_dst']['data'])

        srcToDstLink = CypherLinkUtil.createLink srcEntity._node, dstEntity._node, linkName,
            linkData

    if relation['dst_src']
        linkName  = Link.normalizeName(relation['dst_src']['name'])
        linkData = Link.deserialize(relation['dst_src']['data'])

        dstToSrcLink = CypherLinkUtil.createLink dstEntity._node, srcEntity._node, linkName,
            linkData

    res.status(201).send()

# TODO Implement
exports.unlinkEntity = (req, res, next) ->
    res.status(503).json error: "Not Implemented"

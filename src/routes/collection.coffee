# collection.coffee

_und            = require('underscore')
redis           = require('../models/setup').db.redis

Logger          = require '../util/logger'
Neo             = require '../models/neo'

User            = require '../models/user'
Entity          = require '../models/entity'
Attribute       = require '../models/attribute'
Tag             = require '../models/tag'

Collection      = require '../models/collection'
Rank            = require '../models/rank'

Permission      = require './permission'
Constants       = require('../config').Constants
RedisKey        = require('../config').RedisKey
Security        = require('../config').Security

EntityUtil      = require './entity/util'
Cypher          = require './util/cypher'
CypherBuilder   = Cypher.CypherBuilder
CypherLinkUtil  = Cypher.CypherLinkUtil

Response        = require './util/response'
ErrorDevMessage = Response.ErrorDevMessage

hasPermission = (req, res, next, cb) ->
    ErrorResponse = Response.ErrorResponse(res)

    await
        User.get req.params.id, defer(errOther, other)
        Permission.getUser req, defer(errUser, user)

    isPublic = req.params.id == "public"

    if errUser or errOther
        return cb true, ErrorResponse(500, ErrorDevMessage.dbIssue()), null

    if not other
        return cb true,
            ErrorResponse(400, ErrorDevMessage.customMsg("User does not exist")), null

    # If the user are the same, of course grant permission or the user profile is public
    # Returns a new shallow copy of req with user if authenticated
    if isPublic
        reqWithUser = _und.extend _und.clone(req), user: other
    else
        reqWithUser = _und.extend _und.clone(req), user: user

    if isPublic or (user and other and other._node.id == user._node.id)
        return cb false, null, reqWithUser

    # No Permission
    return cb true, ErrorResponse(401, ErrorDevMessage.permissionIssue()), null

basicAuthentication = Permission.authCurry hasPermission

# create a new collection
_create = (req, res, next) ->
    # Steps
    # create a new collection node
    # get user node
    # connect the two using collection link

    # need a generic validation service
    if not req.body.name or not req.body.collection or not req.body.collectionType
        return Response.ErrorResponse(res)(400,
            ErrorDevMessage.missingParam("name, collection, and collectType is required."))

    req.body.createdBy = req.user.serialize().username
    req.body.user      = req.user
    await Collection.create req.body, defer(err, collection)

    # TODO: Make a generic relationship model class
    CypherLinkUtil.getOrCreateLink Rank, req.user._node, collection._node,
            Constants.REL_COLLECTION,
            {},
            (err, rel) ->

    errs     = []
    entities = []

    await
        for id, ind in collection._node.data.collection
            Entity.get id, defer(errs[ind], entities[ind])

    errs  = []
    links = []

    sCollection = collection.serialize()

    await
        for entity, rank in entities
            if sCollection.collectionType == "ranking"
                relationType = Constants.REL_RANK
            else
                relationType = Constants.REL_COLLECT

            CypherLinkUtil.getOrCreateLink Rank, collection._node, entity._node,
                relationType,
                {rank: rank + 1, collectionName: sCollection.name},
                defer(errs[rank], links[rank])

    Logger.debug "Finished creating links"
    shareToken                       = Security.hashids.encrypt collection._node.id
    publicUser                       = null
    collection._node.data.shareToken = shareToken

    await
        if not collection._node.data.private
            User.get "public", defer(err, publicUser)

        redis.set RedisKey.collectionShareToken(sCollection.id),
            shareToken,
            defer(err, ok)

        collection.save defer(err)

    Response.OKResponse(res)(201, collection.serialize())

# POST /user/:id/collection
exports.create = basicAuthentication _create

# Returns basic information
_show = (req, res, next) ->
    await Collection.get req.params.collectionId, defer(err, collection)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err
    Response.OKResponse(res)(200, collection.serialize())

# Resolve specific collection and deref all content
_showDetail = (req, res, next) ->
    await Collection.get req.params.collectionId, defer(err, collection)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    attrBlobs   = []
    dataBlobs   = []
    sEntities   = []
    sCollection = collection.serialize()

    await
        for entityId, ind in sCollection.collection
            Entity.get entityId, defer(err, sEntities[ind])

    await
        for entity, ind in sEntities
            EntityUtil.getEntityAttributes(entity, defer(attrBlobs[ind]))
            EntityUtil.getEntityData(entity, defer(dataBlobs[ind]))

    for entity, ind in sEntities
        sEntities[ind] = entity.serialize null,
            {attributes: attrBlobs[ind], data: dataBlobs[ind]}

    sCollection.collectionDetails = sEntities
    Response.OKResponse(res)(200, sCollection)

# GET /user/:id/collection/:collectionId
exports.show = basicAuthentication _show

# Update collection info
_edit = (req, res, next) ->
    if not req.body.name or not req.body.collection
        return Response.ErrorResponse(res)(400, ErrorDevMessage.missingParam("name or collection"))

    await Collection.get req.params.collectionId, defer(errR, collection)
    return Response.ErrorResponse(res)(400, errR) if errR

    oldCollection = _und.clone collection.serialize()

    await Collection.put req.params.collection, req.body, defer(errR, collection)
    return Response.ErrorResponse(res)(400, errR) if errR

    newCollection = _und.clone collection.serialize()

    Logger.debug "Old Collection: #{oldCollection}"
    Logger.debug "New Collection: #{newCollection}"

    rankMap = _und.object newCollection.collection, [1..newCollection.collection.length]
    Logger.debug "RankMap: #{rankMap}"

    # remove inactive links
    removedIds = _und.difference oldCollection.collection, newCollection.collection

    Logger.debug "To Remove #{removedIds}"
    entities = []

    if oldCollection.collectionType == "ranking"
        relationType = Constants.REL_RANK
    else
        relationType = Constants.REL_COLLECT

    await
        for entityId, ind in removedIds
            Entity.get entityId, defer(err, entities[ind])
    await
        for entity, ind in entities
            CypherLinkUtil.deleteLink Rank, collection._node, entity._node, relationType

    # add links to new ones
    newIds = _und.difference newCollection.collection, oldCollection.collection

    Logger.debug "To Add #{newIds}"

    entities = []
    await
        for entityId, ind in newIds
            Entity.get entityId, defer(err, entities[ind])

    await
        for entity, ind in entities
            CypherLinkUtil.getOrCreateLink Rank, collection._node, entity._node,
                relationType,
                {rank: rankMap[entity._node.id.toString()], collectionName: newCollection.name},
                (err, rel) ->

    # Update Existing ones
    updateRankIds = _und.intersection newCollection.collection, oldCollection.collection
    Logger.debug "To Update #{updateRankIds}"

    entities = []
    await
        for entityId, ind in updateRankIds
            Entity.get entityId, defer(err, entities[ind])

    errs = []
    rels = []
    await
        for entity, ind in entities
            Logger.debug "for entity #{entity._node.id}@#{rankMap[entity._node.id.toString()]}"
            CypherLinkUtil.updateLink Rank, collection._node, entity._node,
                Constants.REL_RANK,
                {rank: rankMap[entity._node.id.toString()], collectionName: newCollection.name},
                defer(err, rel)

    err = _und.find(errs, (err)->err)
    return cb true, ErrorResponse(500, ErrorDevMessage.dbIssue()), null if err
    Response.OKResponse(res)(200, {})

# PUT /user/:id/collection/:collectionId
exports.edit = basicAuthentication _edit

_delete = (req, res, next) ->
    res.status(503).json error: "Not Implemented"

# DELETE /user/:id/collection/:collection
exports.delete = basicAuthentication _delete

# GET /collection/share/:shareToken
exports.shareView = (req, res, next) ->
    collectionId = Security.hashids.decrypt(req.params.shareToken)

    if parseInt(collectionId)
        req.params.collectionId = collectionId
        _showDetail(req, res, next)
    else
        Response.ErrorResponse(res)(404, ErrorDevMessage.notFound())

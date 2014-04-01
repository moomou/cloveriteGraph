# ranking.coffee
#

_und            = require('underscore')
redis           = require('../models/setup').db.redis

Logger          = require '../util/logger'
Neo             = require '../models/neo'

User            = require '../models/user'
Entity          = require '../models/entity'
Attribute       = require '../models/attribute'
Tag             = require '../models/tag'

Ranking         = require '../models/ranking'
Rank            = require '../models/rank'

Permission      = require './permission'
Constants       = require('../config').Constants
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

# create a new ranking
_create = (req, res, next) ->
    # Steps
    # create a new ranking node
    # get user node
    # connect the two using ranking link

    if not req.body.name or not req.body.ranks
        return Response.ErrorResponse(res)(400, ErrorDevMessage.missingParam("name or rank"))

    req.body.user = req.user
    await Ranking.create req.body, defer(err, ranking)

    # TODO: Make a generic relationship model class
    CypherLinkUtil.getOrCreateLink Rank, req.user._node, ranking._node,
            Constants.REL_RANKING,
            {},
            (err, rel) ->

    errs     = []
    entities = []

    await
        for id, ind in ranking.serialize().ranks
            Entity.get id, defer(errs[ind], entities[ind])

    errs      = []
    rankLinks = []

    await
        for entity, rank in entities
            CypherLinkUtil.getOrCreateLink Rank, ranking._node, entity._node,
                Constants.REL_RANK,
                {rank: rank + 1, rankingName: ranking.serialize().name},
                defer(errs[rank], rankLinks[rank])

    Logger.debug "Finished creating links"

    shareToken                    = Security.hashids.encrypt ranking._node.id
    publicUser                    = null
    ranking._node.data.shareToken = shareToken

    Logger.debug "Ranking is #{ranking._node.data.private}"
    await
        if not ranking._node.data.private
            User.get "public", defer(err, publicUser)

        redis.set "ranking:#{ranking._node.id}:shareToken",
            shareToken,
            defer(err, ok)

        ranking.save defer(err)

    if publicUser
        Logger.debug "LINKING TO PUBLIC USER"
        CypherLinkUtil.createLink publicUser._node, ranking._node,
            Constants.REL_RANKING, {}, (err, rel) ->

    Response.OKResponse(res)(201, ranking.serialize(null))

# POST /user/:id/ranking
exports.create = basicAuthentication _create

_show = (req, res, next) ->
    await Ranking.get req.params.rankingId, defer(err, ranking)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err
    Response.OKResponse(res)(200,ranking.serialize())

# Resolve specific ranking and deref all content
_showDetail = (req, res, next) ->
    await Ranking.get req.params.rankingId, defer(err, ranking)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    rankedEntities  = []
    attrBlobs       = []
    dataBlobs       = []
    sRankedEntities = []
    sRanking        = ranking.serialize()

    await
        for entityId, ind in sRanking.ranks
            Entity.get entityId, defer(err, rankedEntities[ind])

    await
        for entity, ind in rankedEntities
            EntityUtil.getEntityAttributes(entity, defer(attrBlobs[ind]))
            EntityUtil.getEntityData(entity, defer(dataBlobs[ind]))

    for entity, ind in rankedEntities
        sRankedEntities[ind] =
            entity.serialize(null, attributes: attrBlobs[ind], data: dataBlobs[ind])

    sRanking.ranksDetail = sRankedEntities
    Response.OKResponse(res)(200, sRanking)

# GET /user/:id/ranking/:rankingId
exports.show = basicAuthentication _show

# Update ranking info
_edit = (req, res, next) ->
    if not req.body.name or not req.body.ranks
        return Response.ErrorResponse(res)(400, ErrorDevMessage.missingParam("name or rank"))

    await Ranking.get req.params.rankingId, defer(errR, ranking)
    return Response.ErrorResponse(res)(400, errR) if errR

    oldRanking = _und.clone ranking.serialize()
    req.body.createdBy = req.user._node.data.username

    await Ranking.put req.params.rankingId, req.body, defer(errR, ranking)
    return Response.ErrorResponse(res)(400, errR) if errR

    newRanking = _und.clone ranking.serialize()

    Logger.debug "Old Ranking: #{oldRanking}"
    Logger.debug "New Ranking #{newRanking}"

    rankMap = _und.object newRanking.ranks, [1..newRanking.ranks.length]

    Logger.debug "RankMap: #{rankMap}"

    # remove inactive links
    removedRankIds = _und.difference oldRanking.ranks, newRanking.ranks

    Logger.debug "To Remove #{removedRankIds}"

    entities = []

    await
        for entityId, ind in removedRankIds
            Entity.get entityId, defer(err, entities[ind])
    await
        for entity, ind in entities
            CypherLinkUtil.deleteLink Rank, ranking._node, entity._node,
                Constants.REL_RANK

    # add links to new ones
    newRankIds = _und.difference newRanking.ranks, oldRanking.ranks

    Logger.debug "To Add #{newRankIds}"

    entities = []
    await
        for entityId, ind in newRankIds
            Entity.get entityId, defer(err, entities[ind])

    await
        for entity, ind in entities
            CypherLinkUtil.getOrCreateLink Rank, ranking._node, entity._node,
                Constants.REL_RANK,
                {rank: rankMap[entity._node.id.toString()], rankingName: newRanking.name},
                (err, rel) ->

    # Update Existing ones
    updateRankIds = _und.intersection newRanking.ranks, oldRanking.ranks

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
            CypherLinkUtil.updateLink Rank, ranking._node, entity._node,
                Constants.REL_RANK,
                {rank: rankMap[entity._node.id.toString()], rankingName: newRanking.name},
                defer(err, rel)

    err = _und.find(errs, (err)->err)
    return cb true, ErrorResponse(500, ErrorDevMessage.dbIssue()), null if err
    Response.OKResponse(res)(200, {})

# PUT /user/:id/ranking/:rankingId
exports.edit = basicAuthentication _edit

_delete = (req, res, next) ->
    res.status(503).json error: "Not Implemented"

# DELETE /user/:id/ranking/:rankingId
exports.delete = basicAuthentication _delete

# GET /ranking/share/:shareToken
exports.shareView = (req, res, next) ->
    rankingId = Security.hashids.decrypt(req.params.shareToken)

    if parseInt(rankingId)
        req.params.rankingId = rankingId
        _showDetail(req, res, next)
    else
        Response.ErrorResponse(res)(404, ErrorDevMessage.notFound())

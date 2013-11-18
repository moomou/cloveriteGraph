#ranking.coffee
_und = require('underscore')
Logger = require('util')

Setup = require '../models/setup'
db = Setup.db

Neo = require('../models/neo')

User = require('../models/user')
Entity = require('../models/entity')
Attribute = require('../models/attribute')
Tag = require('../models/tag')

Ranking = require('../models/ranking')
Rank = require('../models/rank')

SchemaUtil = require('../models/stdSchema')
Constants = SchemaUtil.Constants

EntityUtil = require('./entity/util')

Cypher = require('./cypher')
CypherBuilder = Cypher.CypherBuilder
CypherLinkUtil = Cypher.CypherLinkUtil

Response = require('./response')
ErrorDevMessage = Response.ErrorDevMessage

Utility = require('./utility')

redis = require('../models/setup').db.redis

hasPermission = (req, res, next, cb) ->
    ErrorResponse = Response.ErrorResponse(res)

    await
        User.get req.params.id, defer(errOther, other)
        Utility.getUser req, defer(errUser, user)

    isPublic = req.params.id == "public"

    err = errUser or errOther
    return cb true, ErrorResponse(500, ErrorDevMessage.dbIssue()), null if err

    # If the user are the same, of course grant permission or the user profile is public
    # Returns a new shallow copy of req with user if authenticated
    if isPublic
        reqWithUser = _und.extend _und.clone(req), user: other
    else
        reqWithUser = _und.extend _und.clone(req), user: user

    if isPublic or (user and other and other._node.id == user._node.id)
        return cb false, null, reqWithUser

    # Cannot access nonexistant user
    return cb true, ErrorResponse(500, ErrorDevMessage.dbIssue()), null if not other

    # No Permission
    return cb true, ErrorResponse(401, ErrorDevMessage.permissionIssue()), null

basicAuthentication = Utility.authCurry hasPermission

# create a new ranking
_create = (req, res, next) ->
    # create a new ranking node
    # get user node
    # connect the two using ranking link
    if not req.body.name or not req.body.ranks
        return Response.ErrorResponse(res)(400, ErrorDevMessage.missingParam("name or rank"))

    console.log req.user
    req.body.createdBy = req.user._node.data.username
    await Ranking.create req.body, defer(err, ranking)

    # TODO: Make a generic relationship model class
    CypherLinkUtil.getOrCreateLink Rank, req.user._node, ranking._node,
            Constants.REL_RANKING,
            {},
            (err, rel) ->

    errs = []
    entities = []

    await
        for id, ind in ranking.serialize().ranks
            Entity.get id, defer(errs[ind], entities[ind])

    errs = []
    rankLinks = []

    await
        for entity, rank in entities
            CypherLinkUtil.getOrCreateLink Rank, ranking._node, entity._node,
                Constants.REL_RANK,
                {rank: rank + 1, rankingName: ranking.serialize().name},
                defer(errs[rank], rankLinks[rank])

    shareToken = SchemaUtil.Security.hashids.encrypt ranking._node.id
    ranking._node.data.shareToken = shareToken

    publicUser = null
    await
        if not ranking._node.data.private
            User.get "public", defer(err, publicUser)

        redis.set "ranking:#{ranking._node.id}:shareToken",
            shareToken,
            defer(err, ok)
        ranking.save defer(err)

    if publicUser
        console.log "LINKING TO PUBLIC USER"
        CypherLinkUtil.createLink publicUser._node, ranking._node,
            Constants.REL_RANKING, {}, (err, rel) ->

    Response.OKResponse(res)(201, ranking.serialize(null, shareToken: shareToken))

# POST /user/:id/ranking
exports.create = basicAuthentication _create

_show = (req, res, next) ->
    await Ranking.get req.params.rankingId, defer(err, ranking)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err
    Response.OKResponse(res)(200,ranking.serialize())

# Get a particular ranking
_showDetail = (req, res, next) ->
    await Ranking.get req.params.rankingId, defer(err, ranking)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    rankedEntities = []
    attrBlobs = []
    sRankedEntities = []
    sRanking = ranking.serialize()

    await
        for entityId, ind in sRanking.ranks
            Entity.get entityId, defer(err, rankedEntities[ind])

    await
        for entity, ind in rankedEntities
            EntityUtil.getEntityAttributes(entity, defer(attrBlobs[ind]))

    for entity, ind in rankedEntities
        sRankedEntities[ind] =
            entity.serialize(null, attributes: attrBlobs[ind])

    Response.OKResponse(res)(200, sRankedEntities)

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

    console.log "Old Ranking"
    console.log oldRanking

    console.log "New Ranking"
    console.log newRanking

    rankMap = _und.object newRanking.ranks, [1..newRanking.ranks.length]

    console.log "RankMap"
    console.log rankMap

    # remove inactive links
    removedRankIds = _und.difference oldRanking.ranks, newRanking.ranks

    console.log "To Remove"
    console.log removedRankIds

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

    console.log "To Add"
    console.log newRankIds

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
    console.log "To Update"
    console.log updateRankIds

    entities = []
    await
        for entityId, ind in updateRankIds
            Entity.get entityId, defer(err, entities[ind])

    errs = []
    rels = []
    await
        for entity, ind in entities
            console.log "for entity " +
                entity._node.id + "@" + rankMap[entity._node.id.toString()]

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
    rankingId = SchemaUtil.Security.hashids.decrypt(req.params.shareToken)
    if parseInt(rankingId)
        req.params.rankingId = rankingId
        _showDetail(req, res, next)
    else
        res.status(404).json error: "Not Found"

#ranking.coffee
_und = require('underscore')
Logger = require('util')

Neo = require('../models/neo')

User = require('../models/user')
Entity = require('../models/entity')
Attribute = require('../models/attribute')
Tag = require('../models/tag')

Ranking = require('../models/ranking')

SchemaUtil = require('../models/stdSchema')
Constants = SchemaUtil.Constants
Utility = require('./utility')

redis = require('../models/setup').db.redis

hasPermission = (req, res, next, cb) ->
    await
        User.get req.params.id, defer(errOther, other)
        Utility.getUser req, defer(errUser, user)

    err = errUser or errOther
    return cb true, res.status(500).json(error: "Unable to retrieve from neo4j"), req if err

    # Cannot access nonexistant user
    return cb true, res.status(401).json(error: "Unable to retrieve from neo4j"), req if not other

    # If the user are the same, of course grant permission
    # Returns a new shallow copy of req with user if authenticated
    reqWithUser = _und.extend _und.clone(req), user: user
    return cb false, null, reqWithUser if user and other and other._node.id == user._node.id

    # No Permission
    return cb true, res.status(401).json(error: "Unauthorized"), req

# POST /user/:id/ranking
exports.create = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes, augReq)
    return errRes if err
    _create augReq, res, next

# create a new ranking
_create = (req, res, next) ->
    # create a new ranking node
    # get user node
    # connect the two using ranking link
    if not req.body.name or not req.body.ranks
        return res.status(400).json(err: "Missing required param name or ranks")

    req.body.createdBy = req.user._node.data.username
    await Ranking.getOrCreate req.body, defer(err, ranking)

    Utility.getOrCreateLink req.user._node, ranking._node,
            Constants.REL_RANKING,
            ranks: ranking.serialize().ranks,
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
            Utility.getOrCreateLink ranking._node, entity._node,
                Constants.REL_RANK,
                {rank: rank, rankingName: ranking.serialize().name},
                defer(errs[rank], rankLinks[rank])

    res.status(201).json ranking.serialize()

# GET /user/:id/ranking/:rankingId
exports.show = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes, augReq)
    return errRes if err
    _show augReq, res, next

# gets all the ranking of the user
_show = (req, res, next) ->
    await Ranking.get req.params.rankingId, defer(err, ranking)
    return next err if err
    res.json ranking.serialize()

# PUT /user/:id/ranking/:rankingId
exports.edit = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes, augReq)
    return errRes if err
    return res.status(400) if not req.body.entity
    _edit augReq, res, next

# Update ranking info
_edit = (req, res, next) ->
    if not req.body.name or not req.body.ranks
        return res.status(400).json(err: "Missing required param name or ranks")

    req.body.name = "#{req.user.username}:#{req.body.name}"

    await Ranking.get req.params.rankingId, defer(errR, ranking)
    oldRanking = _und.clone ranking.serialize()
    await Ranking.put req.params.rankingId, defer(errR, ranking)
    newRanking = _und.clone ranking.serialize()

    rankMap = _und.object newRanking.ranks, [1..newRanking.ranks.length]

    # remove inactive links
    removedRankIds = _und.difference oldRanking.ranks, newRanking.ranks
    entities = []
    await
        for entityId, ind in removedRankIds
            Entity.get entityId, defer(err, entities[ind])
    await
        for entity, ind in entities
            Utility.deleteLink ranking._node, entity._node,
                Constants.REL_RANK

    # add links to new ones
    newRankIds = _und.difference newRanking.ranks, oldRanking.ranks
    entities = []
    await
        for entityId, ind in newRankIds
            Entity.get entityId, defer(err, entities[ind])

    for entity, ind in entities
        Utility.getOrCreateLink ranking._node, entity._node,
            Constants.REL_RANK,
            {rank: rankMap[entity._node.id], rankingName: newRanking.name},
            (err, rel) ->

    # Update Existing ones
    updateRankIds = _und.intersection newRanking.ranks, oldRanking.ranks
    entities = []
    await
        for entityId, ind in newRankIds
            Entity.get entityId, defer(err, entities[ind])

    for entity, ind in entities
        Utility.updateLink ranking._node, entity._node,
            Constants.REL_RANK,
            {rank: rankMap[entity._node.id], rankingName: newRanking.name},
            rankData,
            (err, rel) ->

    res.status(201).json({})

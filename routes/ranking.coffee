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

basicAuthentication = Utility.authCurry hasPermission

# create a new ranking
_create = (req, res, next) ->
    # create a new ranking node
    # get user node
    # connect the two using ranking link
    if not req.body.name or not req.body.ranks
        return res.status(400).json(err: "Missing required param name or ranks")

    req.body.createdBy = req.user._node.data.username
    await Ranking.getOrCreate req.body, defer(err, ranking)

    # TODO: Make a generic relationship model class
    Utility.getOrCreateLink Rank, req.user._node, ranking._node,
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
            Utility.getOrCreateLink Rank, ranking._node, entity._node,
                Constants.REL_RANK,
                {rank: rank + 1, rankingName: ranking.serialize().name},
                defer(errs[rank], rankLinks[rank])

    res.status(201).json ranking.serialize()

# POST /user/:id/ranking
exports.create = basicAuthentication _create

# Get a particular ranking
_show = (req, res, next) ->
    await Ranking.get req.params.rankingId, defer(err, ranking)
    return next err if err
    res.json ranking.serialize()

# GET /user/:id/ranking/:rankingId
exports.show = basicAuthentication _show

# Update ranking info
_edit = (req, res, next) ->
    if not req.body.name or not req.body.ranks
        return res.status(400).json(err: "Missing required param name or ranks")

    await Ranking.get req.params.rankingId, defer(errR, ranking)
    oldRanking = _und.clone ranking.serialize()

    return res.status(400).json(err: errR) if errR

    req.body.createdBy = req.user._node.data.username
    await Ranking.put req.params.rankingId, req.body, defer(errR, ranking)

    return res.status(400).json(err: errR) if errR

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
            Utility.deleteLink Rank, ranking._node, entity._node,
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
            Utility.getOrCreateLink Rank, ranking._node, entity._node,
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

            Utility.updateLink Rank, ranking._node, entity._node,
                Constants.REL_RANK,
                {rank: rankMap[entity._node.id.toString()], rankingName: newRanking.name},
                defer(err, rel)

    err = _und.find(errs, (err)->err)

    res.status(500).json(err: err) if err
    res.status(201).json({})

# PUT /user/:id/ranking/:rankingId
exports.edit = basicAuthentication _edit

_delete = (req, res, next) ->
    res.status(503).json error: "Not Implemented"

# DELETE /user/:id/ranking/:rankingId
exports.delete = basicAuthentication _delete


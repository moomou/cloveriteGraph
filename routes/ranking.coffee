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

    user = user.serialize() if user
    other = other.serialize() if other

    # If the user are the same, of course grant permission
    # Returns a new shallow copy of req with user if authenticated
    reqWithUser = _und.extend _und.clone(req), user: user
    return cb false, null, reqWithUser if user and other and other.id == user.id

    # No Permission
    return cb true, res.status(401).json(error: "Unauthorized"), req

# POST /user/:id/ranking
exports.create = (req, res, next) ->
    await hasPermission req, res, next, refer(err, errRes, augReq)
    return errRes if err
    _create augReq, res, next

# create a new ranking
_create = (req, res, next) ->
    # create a new ranking node
    # get user node
    # connect the two using ranking link

    await Ranking.create req.body, defer(err, ranking)

    Utility.createLink req.user._node, ranking._node,
            Constants.REL_RANKING,
            {},
            (err, rel) ->

    res.status(201).json ranking.serialize()

# GET /user/:id/ranking/:rankingId
exports.show = (req, res, next) ->
    await hasPermission req, res, next, refer(err, errRes, augReq)
    return errRes if err
    _show augReq, res, next

# gets all the ranking of the user
_show = (req, res, next) ->
    await Ranking.get req.params.rankingId, defer(err, ranking)
    return next err if err
    res.json ranking.serialize()

# POST /user/:id/ranking/:rankingId
exports.addNew = (req, res, next) ->
    await hasPermission req, res, next, refer(err, errRes, augReq)
    return errRes if err
    return res.status(400) if not req.body.entity
    _addNew augReq, res, next

# connect the ranking node to the specified entity
_addNew = (req, res, next) ->
    await
        Entity.get req.body.entity, defer(errE, entity)
        Ranking.get req.params.rankingId, defer(errR, ranking)

    err = errE or errR
    return next err if err

    rankData = new Rank req.body
    Utility.createLink req.user._node, ranking._node,
            Constants.REL_RANK,
            rankData,
            (err, rel) ->

    res.status(201).json({})

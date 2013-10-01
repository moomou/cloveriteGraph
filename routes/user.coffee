#entity.coffee
_und = require('underscore')
Logger = require('util')

Neo = require('../models/neo')

User = require('../models/user')
Entity = require('../models/entity')
Attribute = require('../models/attribute')
Tag = require('../models/tag')

Request = require('../models/request')
Recommendation = require('../models/recommendation')

SchemaUtil = require('../models/stdSchema')
Constants = SchemaUtil.Constants

Utility = require('./utility')

redis = require('../models/setup').db.redis

hasPermission = (req, res, next, cb) ->
    await
        User.get req.params.id, defer(errOther, other)
        Utility.getUser req, defer(errUser, user)

    err = errUser or errOther
    return cb true, res.status(500).json(error: "Unable to retrieve from neo4j") if err

    # Cannot access nonexistant user
    return cb true, res.status(401).json(error: "Unable to retrieve from neo4j") if not other

    user = user.serialize() if user
    other = other.serialize() if other

    # If the user are the same, of course grant permission
    return cb false, null if user and other and other.id == user.id

    # No Permission
    return cb true, res.status(401).json(error: "Unauthorized")

getLinkType = (req, res, next, linkType) ->
    await Utility.getUser req, defer(errUser, user)
    return next(errUser) if errUser or not user

    Logger.debug "Getting linkType: #{linkType}"

    await
        user._node.getRelationshipNodes {type: linkType, direction:'out'},
            defer(errGetRelationship, nodes)
    return next(errGetRelationship) if errGetRelationship

    blobs = []
    for node, ind in nodes
        blobs[ind] = (new Entity node).serialize()

    res.json(blobs)

getFeed = (userId, feedType, cb) ->
    # Retrieve latest request feed
    feedId = "user:#{userId}:#{feedType}"
    await redis.lrange feedId, 0, -1, defer(err, feeds)
    return cb true, null if err
    return cb null, _und.map feeds, (feed) -> JSON.parse(feed)

addToFeed = (userId, newFeed, feedType, cb) ->
    feedId = "user:#{userId}:#{feedType}"
    await redis.lpush feedId, JSON.stringify(newFeed), defer(err, result)
    return cb true, null if not result
    return cb null, newFeed

# GET /user/:id/discussion
exports.getDiscussion = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes)
    return errRes if err
    await getFeed req.params.id, "discussionFeed", defer(err, discussionFeed)
    return res.status(500).json(error: "get discussion failed") if err
    return res.json discussionFeed

# GET /user/:id/recommendation
exports.getRecommendation = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes)
    return errRes if err
    await getFeed req.params.id, "recommendationFeed", defer(err, recommendationFeed)
    return res.status(500).json(error: "get recommendationFeed failed") if err
    res.json recommendationFeed

# GET /user/:id/request
exports.getRequest = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes)
    return errRes if err
    await getFeed req.params.id, "requestFeed", defer(err, requestFeed)
    return res.status(500).json(error: "get requestFeed") if err
    res.json requestFeed

# POST  /user/:id/recommendation
exports.sendRecommendation = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes)
    return errRes if err

    cleanedRecommendation = Recommendation.fillMetaData Recommendation.deserialize req.body

    console.log cleanedRecommendation
    await User.find "username", cleanedRecommendation.to, defer(err, receiver)
    return res.status(400).json(error: "No such user exist") if err

    receiver = receiver.serialize()

    await addToFeed receiver, cleanedRecommendation, "recommendationFeed", defer(err, result)
    return res.status(500).json(error: "post recommendationFeed") if err
    res.status(201).json({})

# POST /user/:id/request
exports.sendRequest = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes)
    return errRes if err

    cleanedRequest = Request.fillMetaData Request.deserialize req.body

    console.log cleanedRequest
    await User.find "username", cleanedRequest.to, defer(err, receiver)
    return res.status(400).json(error: "No such user exist") if err

    receiver = receiver.serialize()

    await addToFeed receiver.id, cleanedRequest, "requestFeed", defer(err, result)
    return res.status(500).json(error: "post requestFeed") if err
    res.status(201).json({})

# GET /user/:id/created
exports.getCreated = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes)
    return errRes if err
    getLinkType(req, res, next, Constants.REL_CREATED)

# GET /user/:id/voted
exports.getVoted = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes)
    return errRes if err
    getLinkType(req, res, next, Constants.REL_VOTED)

# GET /user/:id/commented
exports.getCommented = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes)
    return errRes if err
    getLinkType(req, res, next, Constants.REL_COMMENTED)

# GET /user/:id/
exports.getSelf = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes)
    return errRes if err
    await User.get req.params.id, defer(err, user)
    res.json user.serialize()

######################################

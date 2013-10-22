#entity.coffee
_und = require('underscore')
crypto = require('crypto')
Logger = require('util')

User = require('../models/user')
Entity = require('../models/entity')
Attribute = require('../models/attribute')
Tag = require('../models/tag')

Request = require('../models/request')
Recommendation = require('../models/recommendation')
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
    return cb true, res.status(500).json(error: "Unable to retrieve from neo4j"), null if err

    # Cannot access nonexistant user
    return cb true, res.status(401).json(error: "Unable to retrieve from neo4j"), null if not other

    # If the user are the same, of course grant permission
    if user and other and other._node.id == user._node.id
        # Returns a new shallow copy of req with user if authenticated
        reqWithUser = _und.extend _und.clone(req), user: user
        return cb false, null, reqWithUser

    # No Permission
    return cb true, res.status(401).json(error: "Unauthorized"), null

getLinkType =
    (linkType, NodeClass = Entity) ->
        (req, res, next) ->
            Logger.debug "Getting linkType: #{linkType}"

            user = req.user

            await
                user._node.getRelationshipNodes {type: linkType, direction:'out'},
                    defer(errGetRelationship, nodes)
            return next(errGetRelationship) if errGetRelationship

            blobs = []
            for node, ind in nodes
                blobs[ind] = (new NodeClass node).serialize()

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

basicAuthentication = Utility.authCurry hasPermission

basicFeedGetter =
    (feedType) ->
        (req, res, next) ->
            await getFeed req.params.id, feedType, defer(err, feed)
            return res.status(500).json(error: "getting #{feedType} failed") if err
            return res.json feed

basicFeedSetter =
    (FeedClass) ->
        (req, res, next) ->
            cleanedFeed = FeedClass.fillMetaData FeedClass.deserialize req.body

            await User.find "username", cleandFeed.to, defer(err, receiver)
            return res.status(400).json(error: "No such user exist") if err

            receiver = receiver.serialize()

            await addToFeed receiver, cleanedFeed, FeedClass.name, defer(err, result)
            return res.status(500).json(error: "Storing #{FeedClass.name} failed") if err
            res.status(201).json({})

###
# Internal API for creating userNode
###
exports.createUser = (req, res, next) ->
    console.log "In Create user"
    valid = User.validateSchema req.body
    return res.status(400).json error: "Invalid input", input: req.body if not valid

    accessToken = req.headers['x-access-token'] ? "none"

    # unique user id
    await crypto.randomBytes 16, defer(ex, buf)
    userToken = buf.toString('hex')
    userToken = req.body.accessToken = "user_#{userToken}"

    # Access token, after user logs in
    # points to the neo4j userNode Id
    Utility.isAdmin accessToken, (err, isSuperAwesome) ->
        if isSuperAwesome
            await User.create req.body, defer(err, user)
            userObj = user.serialize()

            redis.set userToken, userObj.id, (err, result) ->
                return res.json error: err if err
                return res.status(201).json userObj
        else
            res.status(403).json error: "Permission Denied"

# GET /user/:id/discussion
exports.getDiscussion = basicAuthentication basicFeedGetter "discussionFeed"

# GET /user/:id/recommendation
exports.getRecommendation = basicAuthentication basicFeedGetter "recommendationFeed"

# GET /user/:id/request
exports.getRequest = basicAuthentication basicFeedGetter "requestFeed"

# POST  /user/:id/recommendation
exports.sendRecommendation = basicAuthentication basicFeedSetter Recommendation

# POST /user/:id/request
exports.sendRequest = basicAuthentication basicFeedSetter Request

# GET /user/:id/created
exports.getCreated = basicAuthentication getLinkType Constants.REL_CREATED

# GET /user/:id/voted
exports.getVoted = basicAuthentication getLinkType Constants.REL_VOTED

# GET /user/:id/commented
exports.getCommented = basicAuthentication getLinkType Constants.REL_COMMENTED

# GET /user/:id/ranking
exports.getRanked = basicAuthentication getLinkType Constants.REL_RANKING, Ranking

# GET /user/:id/
exports.getSelf = basicAuthentication (req, res, next) ->
    await User.get req.params.id, defer(err, user)
    res.json user.serialize()

######################################

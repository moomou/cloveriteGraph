# entity.coffee
#

_und            = require('underscore')
crypto          = require('crypto')
redis           = require('../models/setup').db.redis

Logger          = require('util')
Permission      = require('./permission')

User            = require('../models/user')
Entity          = require('../models/entity')
Attribute       = require('../models/attribute')
Tag             = require('../models/tag')

Request         = require('../models/request')
Recommendation  = require('../models/recommendation')
Ranking         = require('../models/ranking')

Constants       = require('../config').Constants

Response        = require('./util/response')
ErrorDevMessage = Response.ErrorDevMessage


hasPermission = (req, res, next, cb) ->
    ErrorResponse = Response.ErrorResponse(res)

    await
        User.get req.params.id, defer(errOther, other)
        Permission.getUser req, defer(errUser, user)

    isPublic = req.params.id == "public"
    if errUser or errOther
        return cb true, ErrorResponse(500, ErrorDevMessage.dbIssue()), null

    # Didn't find user
    if not other
        return cb true,
            ErrorResponse(400,
                ErrorDevMessage.customMsg("user #{req.params.id} does not exist")), null

    # If the user are the same, of course grant permission
    # Returns a new shallow copy of req with user if authenticated

    if isPublic or not user
        reqWithUser = _und.extend _und.clone(req), user: other
    else
        reqWithUser = _und.extend _und.clone(req), user: user

    # The user if public or the user is the owner of the account
    if user and other and other._node.id == user._node.id
        return cb false, null, reqWithUser, unauthenticated: false

    # Grant permission only for public assets under the user
    console.log "Public View"
    return cb false, null, _und.extend reqWithUser, unauthenticated: true

basicAuthentication = Permission.authCurry hasPermission

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
                nodeObj = new NodeClass node
                continue if req.unauthenticated and nodeObj._node.data.private
                blobs.push nodeObj.serialize()

            Response.OKResponse(res)(200, blobs)

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
    ErrorResponse = Response.ErrorResponse(res)

    console.log "In Create user"
    valid = User.validateSchema req.body
    return ErrorResponse 400, ErrorDevMessage.dataValidationIssue("Missing required data") if not valid

    accessToken = req.headers['x-access-token'] ? "none"

    # generate unique user id
    await crypto.randomBytes 16, defer(ex, buf)
    userToken = buf.toString('hex')
    userToken = req.body.accessToken = "user_#{userToken}"

    # Access token, after user logs in
    # points to the neo4j userNode Id.
    Permission.isAdmin accessToken, (err, isSuperAwesome) ->
        if isSuperAwesome
            await User.create req.body, defer(err, user)
            userObj = user.serialize()

            redis.set userToken, userObj.id, (err, result) ->
            Response.OKResponse(res)(201, userObj)
        else
            console.log "You are not awesome."
            ErrorResponse 403, ErrorDevMessage.permissionIssue("Not admin")

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

# GET /user/
exports.getSelf = basicAuthentication (req, res, next) ->
    if not req.unauthenticated
        Response.OKResponse(res)(200, req.user.serialize())
    else
        Response.ErrorResponse(res)(401, ErrorDevMessage.permissionIssue())

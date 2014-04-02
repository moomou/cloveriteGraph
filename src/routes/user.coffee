# entity.coffee
#

_und            = require('underscore')
crypto          = require('crypto')
redis           = require('../models/setup').db.redis

Logger          = require '../util/logger'
Permission      = require './permission'

User            = require '../models/user'
Entity          = require '../models/entity'
Attribute       = require '../models/attribute'
Tag             = require '../models/tag'

Request         = require '../models/request'
Recommendation  = require '../models/recommendation'
Collection      = require '../models/collection'

Constants       = require('../config').Constants

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

    # Didn't find user
    if not other
        return cb true,
            ErrorResponse(400,
                ErrorDevMessage.customMsg("Requested user #{req.params.id} does not exist.")), null

    reqWithUsers = _und.extend _und.clone(req),
        requestedUser: other
        self: user

    # user is the owner of the account
    if user and other and other._node.id == user._node.id
        Logger.info "Private View"
        cb false, null, _und.extend reqWithUsers, authenticated: true

    # Grant permission only for public assets under the user
    else
        Logger.info "Public View"
        cb false, null, _und.extend reqWithUsers, authenticated: false

basicAuthentication = Permission.authCurry hasPermission

getLinkType =
    (linkType, NodeClass = Entity) ->
        (req, res, next) ->
            Logger.debug "Getting linkType: #{linkType}"
            Logger.debug "req.authenticated: #{req.authenticated}"

            user = req.requestedUser

            await
                user._node.getRelationshipNodes {type: linkType, direction:'out'},
                    defer(errGetRelationship, nodes)

            return next(errGetRelationship) if errGetRelationship

            blobs = []
            for node, ind in nodes
                nodeObj = new NodeClass node

                if not req.authenticated and nodeObj._node.data.private
                    continue

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
    Logger.debug "In Create user"

    ErrorResponse = Response.ErrorResponse(res)
    valid         = User.validateSchema req.body

    if not valid
        return ErrorResponse 400, ErrorDevMessage.dataValidationIssue("Missing required data")

    accessToken = req.headers['x-access-token'] ? "none"

    # generate unique user id
    await crypto.randomBytes 16, defer(ex, buf)
    userToken = buf.toString 'hex'
    userToken = req.body.accessToken = "user_#{userToken}"

    # Access token, after user logs in
    # points to the neo4j userNode Id.
    Permission.isSuperAwesome accessToken, (err, isSuperAwesome) ->
        if isSuperAwesome
            await User.create req.body, defer(err, user)
            userObj = user.serialize()

            redis.hset userToken, "id", userObj.id, (err, result) ->
            Response.OKResponse(res)(201, userObj)
        else
            Logger.info "Non admin tried to create user!"
            ErrorResponse 403, ErrorDevMessage.permissionIssue("Not admin")

# GET /user/:id/created
exports.getCreated         = basicAuthentication getLinkType Constants.REL_CREATED

# GET /user/:id/voted
exports.getVoted           = basicAuthentication getLinkType Constants.REL_VOTED

# GET /user/:id/collection
exports.getCollection      = basicAuthentication getLinkType Constants.REL_COLLECTION, Collection

_getUser = (req, res, next) ->
    if req.authenticated
        # return everything
        Response.OKResponse(res)(200, req.requestedUser.serialize())
    else
        # TODO return only public assets
        restricted = _und.omit req.requestedUser.serialize(), "accessToken", "reputation"
        Response.OKResponse(res)(200, restricted)

# GET /user/
exports.getUser = basicAuthentication (req, res, next) ->
    if req.params.id == "self"
        Response.OKResponse(res)(200, req.self.serialize())
    else
        _getUser req, res, next

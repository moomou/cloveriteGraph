#Utility.coffee
_und           = require('underscore')

redis          = require('../models/setup').db.redis

Constants      = require('../config').Constants
AccessLevel    = require('../config').AccessLevel
Logger         = require '../util/logger'

User           = require('../models/user')
Entity         = require('../models/entity')
Attribute      = require('../models/attribute')
Tag            = require('../models/tag')
Link           = require('../models/link')

Cypher         = require './util/cypher'
CypherBuilder  = Cypher.CypherBuilder
CypherLinkUtil = Cypher.CypherLinkUtil

RedisKey       = require('../config').RedisKey

###
# Reads http header to get access token
# Exchange this token for a user unique identifier
# then return the raw neo4j node of the user
###
exports.getUser = getUser = (req, cb) ->
    accessToken = req.headers['x-access-token'] ? "none"

    # Access token, after user logs in
    # points to the neo4j userNode Id
    await
        redis.hget accessToken, "id", defer(err, neoUserId)
    err = user = null

    if not neoUserId # Anonymous users
        Logger.debug "No such user"
        return cb null, null

    Logger.debug "Utility.getUser #{neoUserId}"
    await User.get neoUserId, defer(err, user)

    if err
        cb(err, null) if err
    else
        cb(null, user)

###
# Permission Related Stuff
###
exports.isSuperAwesome = isSuperAwesome = (accessToken, cb) ->
    redis.sismember RedisKey.superToken,
        accessToken,
        (err, res) ->
            cb(err, res)

###
# High level function
###
exports.hasPermission = (user, other, cb) ->
    # No permission for nonexistant object
    if not other
        return cb(null, false)

    isPrivate = other._node.data.private

    if not isPrivate and not user
        return cb null, AccessLevel.READONLY
    else if not user
        return cb null, AccessLevel.NO_ACCESS

    await
        CypherLinkUtil.hasLink user._node,
            other._node,
            Constants.REL_READONLY,
            "all",
            defer errR, readonly,
        CypherLinkUtil.hasLink user._node,
            other._node,
            Constants.REL_MEMBER,
            "all",
            defer errM, isMember
        CypherLinkUtil.hasLink user._node,
            other._node,
            Constants.REL_ADMIN,
            "all",
            defer errA, isAdmin

    err = errR or errM or errA
    return cb err, null if err

    accessLevel = 0
    if readonly
        accessLevel += 1
    if isMember
        accessLevel += 2
    if isAdmin
        accessLevel += 3

    accessLevel = Math.min accessLevel, 3
    cb null, accessLevel

exports.authCurry =
    (hasPermission) -> (cb) ->
        (req, res, next) ->
            await hasPermission req, res, next, defer(err, errRes, augReq)
            return errRes if err
            cb augReq, res, next

#Utility.coffee
_und           = require('underscore')

redis          = require('../models/setup').db.redis

Constants      = require('../config').Constants
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
exports.isAdmin = isAdmin = (accessToken, cb) ->
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

    if not isPrivate
        return cb(null, true)
    if not user
        return cb(null, false)

    await CypherLinkUtil.hasLink user._node,
        other._node,
        Constants.REL_ACCESS,
        "all",
        defer err, path

    if err
        cb err, null
    else
        if path
            cb null, true
        else
            cb null, false

exports.authCurry =
    (hasPermission) ->
        (cb) ->
            (req, res, next) ->
                await hasPermission req, res, next, defer(err, errRes, augReq)
                return errRes if err
                cb augReq, res, next

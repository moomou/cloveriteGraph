_und = require('underscore')

StdSchema = require('../models/stdSchema')
Constants = StdSchema.Constants
Response = StdSchema

User = require('../models/user')
Entity = require('../models/entity')
Attribute = require('../models/attribute')
Tag = require('../models/tag')
Link = require('../models/link')

db = require('../models/setup').db
redis = require('../models/setup').db.redis

###
# Construct key
###
exports.getStartEndIndex = getStartEndIndex = (start, rel, end) ->
    "#{start}_#{rel}_#{end}"

###
# Finds the attribute given entity object
###
exports.getEntityAttributes = (entity, cb) ->
    rels = []
    attrBlobs = []

    await
        entity._node.getRelationshipNodes({type: Constants.REL_ATTRIBUTE, direction:'in'},
            defer(err, nodes))
    return err if err

    await
        for node, ind in nodes
            startendVal = getStartEndIndex(node.id,
                Constants.REL_ATTRIBUTE,
                entity._node.id
            )

            Link.find('startend', startendVal, defer(err, rels[ind]))
            (new Attribute node).serialize(defer(attrBlobs[ind]), entity._node.id)

    for blob, ind in attrBlobs
        if rels[ind]
            linkData = linkData:rels[ind].serialize()
        else
            linkData = linkData:{}

        _und.extend(blob, linkData)

    console.log attrBlobs
    cb attrBlobs

###
# Reads http header to get access token
# Exchange this token for a user unique identifier
# then return the raw neo4j node of the user
###
exports.getUser = getUser = (req, cb) ->
    accessToken = req.headers['access_token'] ? "none"

    # Access token, after user logs in
    # points to the neo4j userNode Id
    await redis.get(accessToken, defer(err, neoUserId))
    err = user = null

    if (not neoUserId) # Anonymous users
        console.log "No such user"
        return cb(null, null)

    console.log "Utility.getUser #{neoUserId}"
    await User.get neoUserId, defer(err, user)

    cb(err, null) if err
    cb(null, user)

###
# Checks if a particular link type exists between the two node
###
exports.hasLink = hasLink = (startNode, otherNode, linkType, dir, cb) ->
    dir ?= "all"

    startNode.path otherNode,
        linkType,
        dir,
        1,              # depth
        'shortestPath', #algo - cannot change?
        (err, path) ->
            return cb(err, null) if err
            if path then cb(null, path) else cb(null, false)

exports.createLink = createLink = (startNode, otherNode, linkType, linkData, cb) ->
    console.log "Creating linkType: #{linkType}"

    startNode.createRelationshipTo otherNode,
        linkType,
        linkData,
        (err, link) ->
            return cb(new Error("Unable to create link"), null) if err
            return cb(null, link)

###
# Create multiple link with the same linkdata
###
exports.createMultipleLinks = createMultipleLinks =
    (startNode, otherNode, links, linkData, cb) ->
        errs = []
        rels = []
        await
            for link, ind in links
                createLink startNode,
                    otherNode,
                    link,
                    linkData,
                    defer(errs[ind], rels[ind])

        err = _und.find(errs, (err) -> err)
        cb(err, rels)

###
# Permission Related Stuff
###
exports.isAdmin = isAdmin = (accessToken, cb) ->
    redis.sismember "superToken",
        accessToken,
        (err, res) ->
            cb(err, res)

### High level function
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

    await
        hasLink user._node,
            other._node,
            Constants.REL_ACCESS,
            "all",
            defer(err, path)

    if not path
        cb(null, false)
    else
        cb(null, true)

###
# Internal API for creating userNode
###
exports.createUser = (req, res, next) ->
    console.log "In Create user"
    accessToken = req.headers['access_token']
    console.log accessToken

    # unique user id
    userToken = req.body.userToken
    console.log userToken

    # Access token, after user logs in
    # points to the neo4j userNode Id
    isAdmin accessToken, (err, isSuperAwesome) ->
        if isSuperAwesome
            await User.create req.body, defer(err, user)
            userObj = user.serialize()

            redis.set userToken, userObj.id, (err, res) ->
                return res.json error: err if err
                return res.json userObj
        else
            res.status(403).json error: "Permission Denied"

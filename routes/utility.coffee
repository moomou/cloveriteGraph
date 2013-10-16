#Utility.coffee
_und = require('underscore')

SchemaUtil = require('../models/stdSchema')
Constants = SchemaUtil.Constants

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
    accessToken = req.headers['x-access-token'] ? "none"

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
exports.getRelationId = getRelationId = (path) ->
    splits = path.relationships[0]._data.self.split('/')
    splits[splits.length - 1]

exports.hasLink = hasLink = (startNode, otherNode, linkType, dir, cb) ->
    dir ?= "all"

    startNode.path otherNode,
        linkType,
        dir,
        1,              # depth
        'shortestPath', #algo - cannot change?
        (err, path) ->
            console.log "hasLink finished"
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

exports.getOrCreateLink = getOrCreateLink = (Class, startNode, otherNode, linkType, linkData, cb) ->
    await
        hasLink startNode,
            otherNode,
            linkType,
            "out",
            defer(err, path)

    console.log "Path"

    if not path
        createLink startNode,
            otherNode
            linkType,
            linkData,
            cb
    else
        relId = getRelationId path
        Class.get relId, cb

exports.updateLink = updateLink = (Class, startNode, otherNode, linkType, linkData, cb) ->
    await
        hasLink startNode,
            otherNode,
            linkType,
            "all",
            defer(err, path)
    if err
        console.log "UpdateLink ERR"
        return cb("Unable to retrieve link", null)
    else if not path
        console.log "UpdateLink Didn't find path"
        return cb("Link does not exist", null)

    console.log "UpdateLinking..."
    console.log linkData

    relId = getRelationId path
    Class.put relId, linkData, cb

exports.deleteLink = deleteLink = (Class, startNode, otherNode, linkType, cb) ->
    await
        hasLink startNode,
            otherNode,
            linkType,
            "out",
            defer(err, path)

    if not path
        return cb(null, null)
    else if err
        return cb("Unable to retrieve link", null)

    relId = getRelationId path

    await
        Class.get relId, defer(err, link)

    #link._node.del()
    link.del()

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

exports.authCurry =
    (hasPermission) ->
        (cb) ->
            (req, res, next) ->
                await hasPermission req, res, next, defer(err, errRes, augReq)
                return errRes if err
                cb augReq, res, next

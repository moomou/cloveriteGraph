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
# Internal API for creating userNode
###

exports._createUser = (req, cb) ->
    accessToken = req.header['ACCESS_TOKEN']
    userToken = req.body.userToken

    # Access token, after user logs in 
    # points to the neo4j userNode Id
    await redis.isMemeber("superToken", isSuperAwesome)

    if isSuperAwesome
        await User.create defer(err, user)
        res.json error: err if err
        res.json user.serialize()

    res.status(403).json error: "Permission Denied"

###
# Reads http header to get access token
# Exchange this token for a user unique identifier
# then return the raw neo4j node of the user
###

exports.getUser = (req, cb) ->
    accessToken = req.header['ACCESS_TOKEN'] ? "none"

    # Access token, after user logs in 
    # points to the neo4j userNode Id
    await redis.get(accessToken, defer(err, neoUserId))

    err = user = null

    if (not neoUserId) # Anonymous users
        return cb(null, null)

    await User.get neoUserId, defer(err, user)
    console.log "Utility.getUser #{user}"

    cb(err, null) if err
    cb(null, user)

#entity.coffee
#Routes to CRUD entities
_und = require('underscore')
rest = require('restler')
Logger = require('util')

Neo = require('../models/neo')

User = require('../models/user')
Entity = require('../models/entity')
Attribute = require('../models/attribute')
Tag = require('../models/tag')

Vote = require('../models/vote')
Link = require('../models/link')

StdSchema = require('../models/stdSchema')

Constants = StdSchema.Constants
Response = StdSchema

Utility = require('./utility')

hasPermission = (req, cb) ->
    await
        User.get req.params.id, defer(errOther, other)
        Utility.getUser req, defer(errUser, user)
    
    err = errUser or errOther
    return cb(new Error("Unable to retrieve from neo4j"), null) if err

    # Cannot access nonexistant user
    if not other
        return cb(null, false)

    # If the user are the same, of course grant permission
    if other._node.data.id == other._node.data.id
        return cb(null, true)

    Utility.hasPermission(user, other, cb)

# TODO: Factor out common code
exports.getCreated = (req, res, next) ->
    await
        hasPermission req, defer(err, authorized)
        Utility.getUser req, defer(errUser, user)

    if not authorized
        console.log "No Permission"
        return res.status(401).json error: "Permission Denied"

    await
        user._node.getRelationshipNodes {type: Constants.REL_CREATED, direction:'out'},
            defer(err, nodes)

    return next(err) if err
    blobs = []

    for node, ind in nodes
        blobs[ind] = (new Entity node).serialize()

    res.json(blobs)

exports.getVoted = (req, res, next) ->
    await
        hasPermission req, defer(err, authorized)
        Utility.getUser req, defer(errUser, user)

    if not authorized
        console.log "No Permission"
        return res.status(401).json error: "Permission Denied"

    await
        user._node.getRelationshipNodes {type: Constants.REL_VOTED, direction:'out'},
            defer(err, nodes)

    return next(err) if err
    blobs = []

    for node, ind in nodes
        blobs[ind] = (new Entity node).serialize()

    res.json(blobs)

exports.getCommented = (req, res, next) ->
    await
        hasPermission req, defer(err, authorized)
        Utility.getUser req, defer(errUser, user)

    if not authorized
        console.log "No Permission"
        return res.status(401).json error: "Permission Denied"

    await
        user._node.getRelationshipNodes {type: Constants.REL_COMMENTED, direction:'out'},
            defer(err, nodes)

    return next(err) if err
    blobs = []

    for node, ind in nodes
        blobs[ind] = (new Entity node).serialize()

    res.json(blobs)

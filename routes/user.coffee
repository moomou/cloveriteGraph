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

hasPermission = (req, res, next, cb) ->
    await
        User.get req.params.id, defer(errOther, other)
        Utility.getUser req, defer(errUser, user)

    err = errUser or errOther
    return cb true, res.status(500).json(error: "Unable to retrieve from neo4j") if err

    # Cannot access nonexistant user
    return cb true, res.status(401).json(error: "Unable to retrieve from neo4j") if not other

    # If the user are the same, of course grant permission
    return cb false, null if other._node.data.id == other._node.data.id

    await Utility.hasPermission user, other, defer(err, authorized)

    return cb true, res.status(500).json(error: "Permission check failed") if err
    return cb true, res.status(401).json(error: "Permission Denied") if not authorized
    return cb false, null

getLinkType= (req, res, next, linkType) ->
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

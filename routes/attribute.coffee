#attribute.coffee
#Routes to CRUD entities
Neo = require('../models/neo')
Entity = require('../models/entity')
Attribute = require('../models/attribute')
Constants = require('../models/stdSchema')
Response = require('../models/stdSchema')

# POST /attribute
exports.create = (req, res, next) ->
    await Attribute.create req.body, defer(err, attr)
    return next(err) if err
    res.json attr.serialize()

# GET /attribute/?q=
exports.search = (req, res, next) ->

# GET /attribute/:id
exports.show = (req, res, next) ->
    await Attribute.get req.params.id, defer(err, attr)
    return next err if err
    res.json(attr.serialize())

# PUT /attribute/:id
exports.edit = (req, res, next) ->
    await Attribute.put req.params.id, req.body, defer(err, attr)
    return next(err) if err
    res.json attr.serialize()

# DELETE /attribute/:id
exports.del = (req, res, next) ->
    await Attribute.get req.params.id, defer(err, entity)
    return next(err) if err

    await entity.del defer(err)

    return next(err) if err
    res.json({})

# POST /attribute/:id/:relation
###
    Connect another attribute to current one using [relation]
    DATA : {
        action: add/rm
        other: attributeId,
    }
###

# GET /attribute/:id/:relation
###
    List all attribute related to this attribute through [relation]
###

#GET /entity/:id/attribute
exports.listEntity = (req, res, next) ->
    await Entity.get req.params.id, defer(errE, entity)
    await
        entity._node.getRelationshipNodes {type: Constants.REL_ATTRIBUTE, direction:'in'},
            defer(err, nodes)

    res.json((new Attribute node).serialize() for node in nodes)


#attribute.coffee
#Routes to CRUD entities
require('source-map-support').install()
_und = require('underscore')

Neo = require('../models/neo')
Entity = require('../models/entity')
Attribute = require('../models/attribute')
Tag = require('../models/tag')

SchemaUtil = require('../models/stdSchema')
Constants = SchemaUtil.Constants

# GET /attribute/search/
exports.search = (req, res, next) ->
    res.redirect "/#{Constants.API_VERSION}/search/?q=#{req.query['q']}"

# POST /attribute
exports.create = (req, res, next) ->
    await Attribute.create req.body, defer(err, attr)
    return next(err) if err

    await attr.serialize defer(blob)
    res.json blob

# GET /attribute/:id
exports.show = (req, res, next) ->
    if isNaN req.params.id
        return res.json {}

    await Attribute.get req.params.id, defer(err, attr)
    return next err if err

    entityId = req.query['entityId'] ? null

    await attr.serialize(defer(blob), entityId)
    res.json blob

# PUT /attribute/:id
exports.edit = (req, res, next) ->
    await Attribute.put req.params.id, req.body, defer(err, attr)
    return next(err) if err

    await attr.serialize defer(blob)
    res.json blob

# DELETE /attribute/:id
exports.del = (req, res, next) ->
    await Attribute.get req.params.id, defer(err, entity)
    return next(err) if err

    await entity.del defer(err)

    return next(err) if err
    res.status(204).send()

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

#GET /attribute/:id/entity
exports.listEntity = (req, res, next) ->
    await Attribute.get req.params.id, defer(errAttr, attr)
    return next errAttr if errAttr

    await #check direction field
        attr._node.getRelationshipNodes {type: Constants.REL_ATTRIBUTE, direction:'out'},
            defer(err, nodes)

    return next err if err

    blobs = []

    await
        for node, ind in nodes
            (new Entity node).serialize defer(blobs[ind])

    res.json(blob for blob in blobs)

#entity.coffee
#Routes to CRUD entities

Neo = require('../models/neo')
Entity = require('../models/entity')
Attribute = require('../models/attribute')
Constants = require('../models/stdSchema')
Response = require('../models/stdSchema')

# POST /entity
exports.create = (req, res, next) ->
    await Entity.create req.body, defer(err, entity)
    return next(err) if err

    res.status(201).json entity.serialize()

#GET /entity/?q=
exports.search = (req, res, next) ->

#GET /entity/:id
exports.show = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)
    return next err if err
    res.json(entity.serialize())

#PUT /entity/:id
exports.edit = (req, res, next) ->
    await Entity.put req.params.id, req.body, defer(err, entity)
    return next err if err

    res.json(entity.serialize())

#DELETE /entity/:id
exports.del = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)
    return next err if err

    await entity.del defer(err)

    return next err if err

    res.statusCode = 204
    res.send()

#POST /entity/:id/attribute
exports.addAttribute = (req, res, next) ->
    await
        Entity.get req.params.id, defer(errE, entity)
        Attribute.getOrCreate req.body, defer(errA, attr)

    if errE or errA
        errorRes = Response.ErrorResponse(
            "Error Occured",
            "Unknown"
        )

        return res.statusCode(500).json errorRes.serialize()

    await attr._node.createRelationshipTo entity._node,
        Constants.REL_ATTRIBUTE, {},
        defer(err, rel)

    res.status(201).json (new Neo rel).serialize()

#DELETE /entity/:eId/attribute/:aId
exports.delAttribute = (req, res, next) ->
    await Entity.get req.params.eId, defer(errE, entity)
    await Attribute.get req.params.aId, defer(errA, attr)

#GET /entity/:id/attribute
exports.listAttribute = (req, res, next) ->
    await Entity.get req.params.id, defer(errE, entity)
    await
        entity._node.getRelationshipNodes {type: Constants.REL_ATTRIBUTE, direction:'in'},
            defer(err, nodes)

    res.json((new Attribute node).serialize() for node in nodes)

#POST /entity/:id/attribute/:id/vote
exports.voteAttribute = (req, res, next) ->
    await Entity.get req.params.eId, defer(errE, entity)
    await Attribute.get req.params.aId, defer(errA, attr)

    vote = new VoteLink req.body

    entity.vote attr, vote (err) ->
        return res.statusCode(500) if err
        res.send()

#POST
exports.relation = (req, res, next) ->
    await
        Entity.get req.params.id, defer(err, entity)
        Entity.get req.body.otherId, defer(err, other)
    
    switch req.body.action
        when "add" then entity.linkEntity other, req.params.relation, (err) -> console.log(err)
        when "remove" then entity.unlinkEntity other, req.params.relation, (err) -> console.log(err)

#entity.coffee
#Routes to CRUD entities
_und = require('underscore')
Neo = require('../models/neo')
Entity = require('../models/entity')
VoteLink = require('../models/votelink')
Attribute = require('../models/attribute')
StdSchema = require('../models/stdSchema')
Constants = StdSchema.Constants
Response = StdSchema

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
    await
        Entity.get req.params.eId, defer(errE, entity)
        Attribute.get req.params.aId, defer(errA, attr)
   
    if errE
        console.log "errE"
        return next(errE)
    if errA
        console.log "errA"
        return next(errA)

    voteData = _und.clone req.body
    voteData.ipAddr = req.header['x-forwarded-for'] or req.connection.remoteAddress
    voteData.browser = req.useragent.Browser
    voteData.os = req.useragent.OS
    voteData.lang = req.headers['accept-language']

    vote = new VoteLink voteData
    
    entity.vote attr, vote, (err, voteTally) ->
        return res.statusCode(500) if err
        res.send(voteTally)

#POST
exports.relation = (req, res, next) ->
    await
        Entity.get req.params.eId, defer(errE, entity)
        Attribute.get req.params.aId, defer(errA, attr)
    
    switch req.body.action
        when "add" then entity.linkEntity other, req.params.relation, (err) -> console.log(err)
        when "remove" then entity.unlinkEntity other, req.params.relation, (err) -> console.log(err)

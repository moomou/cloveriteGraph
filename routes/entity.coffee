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

    await entity.serialize defer blob
    res.status(201).json blob

#GET /entity/?q=
exports.search = (req, res, next) ->

#GET /entity/:id
exports.show = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)
    return next err if err

    await entity.serialize defer blob
    res.json blob

#PUT /entity/:id
exports.edit = (req, res, next) ->
    await Entity.put req.params.id, req.body, defer(err, entity)
    return next err if err

    await entity.serialize defer blob
    res.json blob

#DELETE /entity/:id
exports.del = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)
    return next err if err

    await entity.del defer(err)

    return next err if err

    res.statusCode(204).send()

#POST /entity/:id/attribute
exports.addAttribute = (req, res, next) ->
    await
        Entity.get req.params.id, defer(errE, entity)
        Attribute.getOrCreate req.body, defer(errA, attr)

        return next(errE) if errE
        return next(errA) if errA

    await attr._node.createRelationshipTo entity._node,
        Constants.REL_ATTRIBUTE, {},
        defer(err, rel)

    await (new Neo rel).serialize defer blob
    res.status(201).json blob

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

    blobs = []
    await
        for node, ind in nodes
            (new Attribute node).serialize defer(blobs[ind]), entity._node.id

    res.json(blob for blob in blobs)

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

# POST /entity/:id/relation?
exports.listRelation = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)

    return next(err) if err
    
    relType = req.params.relation ? ''

    await entity._node.outgoing relType, defer(err, rels)

    blobs = []
    await
        for rel, ind in rels

            extraData = {
                type: rel.type,
                start: rel.start.id,
                end: rel.end.id
            }

            (new Neo rel).serialize defer(blobs[ind]), extraData
                
    res.json(blob for blob in blobs)

# POST /entity/:id/relation/entity/:id
exports.linkEntity = (req, res, next) ->
    await
        Entity.get req.params.srcId, defer(errSrc, srcEntity)
        Entity.get req.params.dstId, defer(errDst, dstEntity)

    return next(errSrc) if errSrc
    return next(errDst) if errDst
    
    relation = req.body

    await
        if relation['src_dst']
            srcEntity._node createRelationshipTo dstEntity._node, relation['src_dst'],
                defer(errSrc, src_dstRel)

        if relation['dst_src']
            dstEntity._node createRelationshipTo dstEntity._node, relation['dst_src'],
                defer(errDst, dst_srcRel)
    
    return next(errSrc) if errSrc
    return next(errDst) if errDst

    res.statusCode(202).send()

exports.unlinkEntity = (req, res, next) ->

#entity.coffee
#Routes to CRUD entities
require('source-map-support').install()

_und = require('underscore')

Neo = require('../models/neo')

Entity = require('../models/entity')
Attribute = require('../models/attribute')
Tag = require('../models/tag')

Vote = require('../models/vote')
Link = require('../models/link')

StdSchema = require('../models/stdSchema')
Constants = StdSchema.Constants
Response = StdSchema

# GET /entity/search/
exports.search = (req, res, next) ->
    res.redirect "/search/?q=#{req.query['q']}"

# POST /entity
exports.create = (req, res, next) ->
    errs = []
    tagObjs = []
    tags = req.body['tags'] ? []

    await
        for tagName, ind in tags
            Tag.getOrCreate tagName, defer(errs[ind], tagObjs[ind])

    err = _und.find(errs, (err) -> err)
    return next(err) if err

    await Entity.create req.body, defer(err, entity)
    return next(err) if err

    #"tag" entity
    for tagObj, ind in tagObjs
        tagObj._node.createRelationshipTo entity._node,
            Constants.REL_TAG, {},
            (err, rel) ->

    await entity.serialize defer blob
    res.status(201).json blob

#GET /entity/:id
exports.show = (req, res, next) ->
    if isNaN req.params.id
        return res.json {}

    await
        Entity.get req.params.id, defer(err, entity)

    return next err if err
    attrBlobs = []

    if req.query['attr'] != "false"
        await
            entity._node.getRelationshipNodes {type: Constants.REL_ATTRIBUTE, direction:'in'},
                defer(err, nodes)

        await
            for node, ind in nodes
                (new Attribute node).serialize(defer(attrBlobs[ind]), entity._node.id)

        return next err if err
        await entity.serialize defer(entityBlob), attributes: attrBlobs
    else
        await entity.serialize defer entityBlob

    res.json entityBlob

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

    res.status(204).send()

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

    await attr.serialize defer blob
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

    vote = new Vote voteData

    entity.vote attr, vote, (err, voteTally) ->
        return res.status(500) if err
        res.send(voteTally)

# GET /entity/:id/relation?
exports.listRelation = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)
    return next(err) if err
    
    relType = req.params.relation ? ''
    
    await
        entity._node.outgoing relType, defer(err, rels)

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
            link = new Link relation['src_dst']
            console.log link
            srcEntity._node.createRelationshipTo dstEntity._node,
                link.name,
                link.data,
                defer(es, src_dstRel)
            
        if relation['dst_src']
            link = new Link relation['dst_src']
            console.log link
            dstEntity._node.createRelationshipTo srcEntity._node,
                link.name,
                link.data,
                defer(et, dst_srcRel)

    res.status(201).send()

exports.unlinkEntity = (req, res, next) ->

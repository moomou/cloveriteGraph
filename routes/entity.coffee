#entity.coffee
#Routes to CRUD entities
_und = require('underscore')
rest = require('restler')
Logger = require('util')

Neo = require('../models/neo')

Entity = require('../models/entity')
Attribute = require('../models/attribute')
Tag = require('../models/tag')

Vote = require('../models/vote')
Link = require('../models/link')

StdSchema = require('../models/stdSchema')

Constants = StdSchema.Constants
Response = StdSchema

Utility = require('./utility')

# Support Functions
getOutgoingRelsCypherQuery = (startId, relType) ->
    cypher = "START n=node(#{startId}) MATCH n-[r]->other "

    if relType == "relation"
        cypher += "WHERE type(r) <> '_VOTE'"
    else
        cypher += "WHERE type(r) = '#{Link.normalizeName relType}'"

    cypher += " RETURN r;"

getJSONData = (remoteAddress, cb) ->
    rest.get(remoteAddress).on 'complete', (remoteData, remoteRes) ->
        if not remoteRes?
            cb("")
        else if remoteRes? and remoteRes.headers['content-type'].indexOf('application/json') isnt -1
            cb(remoteData)
        else
            cb("N/A")

# END --

# GET /entity/search/
exports.search = (req, res, next) ->
    console.log "HI"
    res.redirect "/search/?q=#{req.query['q']}"

###
# Entity section
###

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

    if req.query['attr'] != "false"
        await
            Utility.getEntityAttributes(entity, defer(attrBlobs))
        entityBlob = entity.serialize(null, attributes: attrBlobs)
    else
        entityBlob = entity.serialize(null, entityBlob)

    res.json entityBlob

#PUT /entity/:id
exports.edit = (req, res, next) ->
    await Entity.put req.params.id, req.body, defer(err, entity)
    return next(err) if err

    # Need to refactor later
    errs = []
    tagObjs = []
    tags = req.body['tags'] ? []

    await
        for tagName, ind in tags
            Tag.getOrCreate tagName, defer(errs[ind], tagObjs[ind])

    err = _und.find(errs, (err) -> err)
    return next(err) if err

    #"tag" entity
    for tagObj, ind in tagObjs
        tagObj._node.createRelationshipTo entity._node,
            Constants.REL_TAG, {},
            (err, rel) ->

    await entity.serialize defer blob
    res.json blob

#DELETE /entity/:id
exports.del = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)
    return next err if err

    await entity.del defer(err)

    return next err if err

    res.status(204).send()

###
# Entity Attribute Section
###

# GET /entity/:id/attribute
exports.listAttribute = (req, res, next) ->
    await Entity.get req.params.id, defer(errE, entity)
    return next(err) if err

    await
        entity._node.getRelationshipNodes {type: Constants.REL_ATTRIBUTE, direction:'in'},
            defer(err, nodes)

    return next(err) if err

    rels = []
    blobs = []

    await
        for node, ind in nodes
            startendVal = Utility.getStartEndIndex(node.id,
                Constants.REL_ATTRIBUTE,
                req.params.id
            )

            Link.find('startend', startendVal, defer(err, rels[ind]))
            (new Attribute node).serialize defer(blobs[ind]), entity._node.id

    for blob, ind in blobs
        if rels[ind]
            linkData = linkData:rels[ind].serialize()
        else
            linkData = linkData:{}

        _und.extend(blob, linkData)

    res.json(blobs)

# POST /entity/:id/attribute
exports.addAttribute = (req, res, next) ->

    # Clean Data
    data = _und.clone req.body
    delete data['id']

    # Retrieve the 2 entities
    await
        Entity.get req.params.id, defer(errE, entity)
        Attribute.getOrCreate data, defer(errA, attr)

    return next(errE) if errE
    return next(errA) if errA

    await
        entity._node.path attr._node,
            Constants.REL_ATTRIBUTE,
            "all",   #direction
            1,       # depth
            'shortestPath', #algo - cannot change?
            defer(errPath, path)

    return next(errPath) if errPath

    linkData = Link.normalizeData _und.clone(req.body || {})
    linkData['startend'] = Utility.getStartEndIndex(
        attr._node.id,
        Constants.REL_ATTRIBUTE,
        req.params.id
    )

    console.log "__NEW__"
    console.log linkData
    console.log "__END__"

    # If Path already exists
    if path
        splits = path.relationships[0]._data.self.split('/')
        relId = splits[splits.length - 1]

        await
            Link.get relId, defer(err, link)
        existingLinkData = link.serialize()

        console.log "__EXISTING__"
        console.log existingLinkData
        console.log "__END__"

        # Updating Remote Data
        if existingLinkData.srcURL != linkData.srcURL
            await getJSONData(linkData.srcURL, defer(value))
            linkData.value = value
            linkData.type = if not isNaN(value) then Constants.ATTR_NUMERIC else Constants.ATTR_REFERENCE

        linkData = _und.extend existingLinkData, linkData

        console.log "__MERGED__"
        console.log linkData
        console.log "__END__"

        Link.put relId, linkData, ->
        rel = path.relationships[0]
    else
        await getJSONData(linkData.srcURL, defer(value))
        linkData.value = value
        linkData.type = if not isNaN(value) then Constants.ATTR_NUMERIC else Constants.ATTR_REFERENCE
        linkData = Link.fillMetaData(linkData)

        await attr._node.createRelationshipTo entity._node,
            Constants.REL_ATTRIBUTE,
            linkData,
            defer(err, rel)
        return next(err) if err

    Link.index(rel, linkData)

    await attr.serialize defer blob
    _und.extend blob, linkData: linkData
    res.status(201).json blob

#DELETE /entity/:eId/attribute/:aId
exports.delAttribute = (req, res, next) -> #TODO
    await Entity.get req.params.eId, defer(errE, entity)
    await Attribute.get req.params.aId, defer(errA, attr)

#GET /entity/:id/attribute/:id
exports.getAttribute = (req, res, next) ->
    attrId = req.params.aId
    entityId = req.params.eId

    startendVal = Utility.getStartEndIndex(attrId,
        Constants.REL_ATTRIBUTE,
        entityId
    )

    await
        Link.find('startend', startendVal, defer(errLink, rel))
        Attribute.get attrId, defer(errAttr, attr)

    err = errLink || errAttr
    return next(err) if err

    blob = {}
    await attr.serialize(defer(blob), entityId)

    _und.extend(blob, linkData: rel.serialize())
    res.json blob

#PUT /entity/:id/attribute/:id
exports.updateAttributeLink = (req, res, next) ->
    attrId = req.params.aId
    entityId = req.params.eId

    linkData = _und.clone(req.body['linkData'] || {})

    await
        Attribute.get attrId, defer(errAttr, attr)
        Link.put(linkData['id'], linkData, defer(errLink, rel))

    err = errAttr || errLink
    return next(err) if err

    blob = attr.serialize()
    _und.extend blob, linkData: rel.serialize()

    res.json blob

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


###
# Entity Relation section
###

# GET /entity/:id/relation
exports.listRelation = (req, res, next) ->
    entityId = req.params.id
    relType = req.params.relation

    query = getOutgoingRelsCypherQuery(entityId, relType)

    await Neo.query Link, query, {}, defer(err, rels)

    blobs = []
    await
        for rel, ind in rels
            rel = new Link rel.r

            tmp = rel._node._data.start.split('/')
            startId = tmp[tmp.length - 1]

            tmp = rel._node._data.end.split('/')
            endId = tmp[tmp.length - 1]

            extraData = {
                type: rel._node._data.type,
                start: startId
                end: endId
            }

            rel.serialize defer(blobs[ind]), extraData

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
            linkName  = Link.normalizeName(relation['src_dst']['name'])
            linkData = Link.deserialize(relation['src_dst']['data'])

            srcEntity._node.createRelationshipTo dstEntity._node,
                linkName,
                linkData,
                defer(es, src_dstRel)

    await
        if relation['dst_src']
            linkName  = Link.normalizeName(relation['dst_src']['name'])
            linkData = Link.deserialize(relation['dst_src']['data'])

            dstEntity._node.createRelationshipTo srcEntity._node,
                linkName,
                linkData,
                defer(et, dst_srcRel)

    res.status(201).send()

exports.unlinkEntity = (req, res, next) ->

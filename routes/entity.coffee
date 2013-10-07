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
Comment = require('../models/comment')

SchemaUtil = require('../models/stdSchema')
Constants = SchemaUtil.Constants

Search = require('./search')
Utility = require('./utility')

redis = require('../models/setup').db.redis

# Support Functions
getOutgoingRelsCypherQuery = (startId, relType) ->
    cypher = "START n=node(#{startId}) MATCH n-[r]->other "

    if relType == "relation"
        cypher += "WHERE type(r) <> #{Constants.REL_VOTED} "
    else
        cypher += "WHERE type(r) = '#{Link.normalizeName relType}'"

    cypher += " RETURN r;"

# Remote web service for reading
# numeric json data
getJSONData = (remoteAddress, cb) ->
    if not remoteAddress
        return cb("N/A")
    rest.get(remoteAddress).on 'complete', (remoteData, remoteRes) ->
        if not remoteRes?
            cb("")
        else if remoteRes? and remoteRes.headers['content-type'].indexOf('application/json') isnt -1
            cb(remoteData)
        else
            cb("N/A")

getDiscussionId = (entityId) ->
    "entity:#{entityId}:discussion"

getRelationId = (path) ->
    splits = path.relationships[0]._data.self.split('/')
    splits[splits.length - 1]

hasPermission = (req, res, next, cb) ->
    cb true, res.status(400).json(error: "Missing param id"), null if isNaN req.params.id

    await
        Entity.get req.params.id, defer(errEntity, entity)
        Utility.getUser req, defer(errUser, user)

    err = errUser or errEntity
    return cb true, res.status(500).json(error: "Unable to retrieve from neo4j"), null if err

    # Return authorized if not private and user is anonymous
    return cb false, null, req if not entity._node.data.private and not user

    await Utility.hasPermission user, entity, defer(err, authorized)

    return cb true, res.status(500).json(error: "Permission check failed"), null if err
    return cb true, res.status(401).json(error: "Permission Denied"), null if not authorized

    # Returns a new shallow copy of req with user if authenticated
    reqWithUser = _und.extend _und.clone(req), user: user
    return cb false, null, reqWithUser

# END -

# GET /entity/search/
exports.search = (req, res, next) ->
    Search.searchHandler(req, res, next)
    #res.redirect "/#{Constants.API_VERSION}/search/?q=#{req.query['q']}"

###
# Entity section
###

# POST /entity - Please note, permission NOT required
exports.create = (req, res, next) ->
    await Utility.getUser req, defer(err, user)
    return next err if err

    # anonymous user cannot create private entity
    req.body['private'] = false if not user
    console.log "Creating Entity"

    errs = []
    tagObjs = []

    # Create Entity and Tags
    await
        Entity.create req.body, defer(err, entity)

    await
        for tagName, ind in entity.serialize().tags
            Tag.getOrCreate tagName, defer(errs[ind], tagObjs[ind])

    err = err or _und.find(errs, (err) -> err)
    return next(err) if err

    linkData = Link.fillMetaData({})

    # "tag" entity
    for tagObj, ind in tagObjs
        Utility.createLink tagObj._node, entity._node,
            Constants.REL_TAG,
            linkData,
            (err, rel) ->

        if user
            Utility.createLink user._node, tagObj._node,
                Constants.REL_TAG,
                linkData,
                (err, rel) ->

    # User is not defined for anonymous users
    if user
        await Utility.createMultipleLinks user._node,
            entity._node,
            [Constants.REL_CREATED, Constants.REL_ACCESS, Constants.REL_MODIFIED],
            linkData,
            defer(err, rels)

    await entity.serialize defer blob
    res.status(201).json blob

# GET /entity/:id
exports.show = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes, augReq)
    return errRes if err
    _show(augReq, res, next)

_show = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)
    return next err if err

    if req.query['attr'] != "false"
        await
            Utility.getEntityAttributes(entity, defer(attrBlobs))
        entityBlob = entity.serialize(null, attributes: attrBlobs)
    else
        entityBlob = entity.serialize(null, entityBlob)

    res.json entityBlob

# PUT /entity/:id
exports.edit = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes, augReq)
    return errRes if err
    _edit(augReq, res, next)

_edit = (req, res, next) ->
    await Entity.put req.params.id, req.body, defer(errMsg, entity)
    return res.status(400).json error: errMsg, input: req.body if errMsg

    errs = []
    tagObjs = []

    await
        for tagName, ind in entity.serialize().tags
            Tag.getOrCreate tagName, defer(errs[ind], tagObjs[ind])

    err = _und.find(errs, (err) -> err)
    return next(err) if err

    linkData = Link.fillMetaData({})

    # "tag" entity
    for tagObj, ind in tagObjs
        # This is blocking
        await
            Utility.hasLink tagObj._node,
                entity._node,
                Constants.REL_ATTRIBUTE,
                "all",
                defer(err, pathExists)

        if not pathExists
            Utility.createLink tagObj._node,
                entity._node,
                Constants.REL_TAG,
                linkData,
                (err, rel) ->

    await entity.serialize defer blob
    res.json blob

# DELETE /entity/:id
exports.del = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes, augReq)
    return errRes if err
    _del(augReq, res, next)

_del = (req, res, next) ->
    await Entity.put req.params.id, req.body, defer(err, entity)
    return next(err) if err

    await Entity.get req.params.id, defer(err, entity)
    return next err if err

    await entity.del defer(err)

    return next err if err
    res.status(204).send()

###
# Entity Use Section
###
exports.showUsers = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes, augReq)
    return errRes if err
    _showUsers(req, res, next)

_showUsers = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)
    return next err if err

    await
        entity._node.getRelationshipNodes {type: Constants.REL_MODIFIED, direction:'in'},
            defer(err, nodes)

    return next(err) if err
    blobs = []

    for node, ind in nodes
        blobs[ind] = (new User node).serialize()

    res.json(blobs)

###
# Entity Attribute Section
###

# GET /entity/:id/attribute
exports.listAttribute = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes, augReq)
    return errRes if err
    _listAttribute(augReq, res, next)

_listAttribute = (req, res, next) ->
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
    await hasPermission req, res, next, defer(err, errRes, augReq)
    return errRes if err
    _addAttribute augReq, res, next

_addAttribute = (req, res, next) ->
    valid = Attribute.validateSchema req.body
    return res.status(400).json error: "Invalid input", input: req.body if not valid

    # Clean Data
    data = _und.clone req.body
    delete data['id']

    # Retrieve the 2 entities
    await
        Entity.get req.params.id, defer(errE, entity)
        Attribute.getOrCreate data, defer(errA, attr)

    err = errE or errA
    return next(err) if err

    linkData = Link.normalizeData _und.clone(req.body || {})
    linkData['startend'] = Utility.getStartEndIndex(
        attr._node.id,
        Constants.REL_ATTRIBUTE,
        req.params.id
    )

    console.log "__NEW__"
    console.log linkData
    console.log "__END__"

    # hasLink returns the link if it exists
    await Utility.hasLink entity._node,
        attr._node,
        Constants.REL_ATTRIBUTE,
        "all",
        defer(err, path)

    # If Path already exists
    if path
        relId = getRelationId path

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
            linkData.type =
                if not isNaN(value) then Constants.ATTR_NUMERIC else Constants.ATTR_REFERENCE

        linkData = _und.extend existingLinkData, linkData

        console.log "__MERGED__"
        console.log linkData
        console.log "__END__"

        Link.put relId, linkData, ->
        rel = path.relationships[0]
    else
        await getJSONData(linkData.srcURL, defer(value))
        linkData.value = value
        linkData.type =
            if not isNaN(value) then Constants.ATTR_NUMERIC else Constants.ATTR_REFERENCE

        linkData = Link.fillMetaData(linkData)
        await Utility.createLink attr._node,
            entity._node,
            Constants.REL_ATTRIBUTE,
            linkData,
            defer(err, rel)

        return next(err) if err

    Link.index(rel, linkData)

    await attr.serialize defer blob
    _und.extend blob, linkData: linkData
    res.status(201).json blob

# TODO DELETE /entity/:eId/attribute/:aId
exports.delAttribute = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes, augReq)
    return errRes if err
    _delAttribute(augReq, res, next)

_delAttribute = (req, res, next) ->
    res.status(503).json error: "Not Implemented"

#GET /entity/:id/attribute/:id
exports.getAttribute = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes, augReq)
    return errRes if err
    _getAttribute(augReq, res, next)

_getAttribute =(req, res, next) ->
    entityId = req.params.eId
    attrId = req.params.aId

    return res.status(401).json error: "Missing attribute id" if not attrId

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
    await hasPermission req, res, next, defer(err, errRes, augReq)
    return errRes if err
    _updateAttributeLink(augReq, res, next)

_updateAttributeLink = (req, res, next) ->
    entityId = req.params.eId
    attrId = req.params.aId
    linkData = _und.clone(req.body['linkData'] || {})

    return res.status(401).json error: "Missing attribute id" if not attrId

    await
        Attribute.get attrId, defer(errAttr, attr)
        Link.put(linkData['id'], linkData, defer(errLink, rel))

    err = errAttr || errLink
    return next(err) if err

    blob = attr.serialize()
    _und.extend blob, linkData: rel.serialize()

    res.json blob

# POST /entity/:id/attribute/:id/vote
exports.voteAttribute = (req, res, next) ->
    await
        Entity.get req.params.eId, defer(errE, entity)
        Attribute.get req.params.aId, defer(errA, attr)
        Utility.getUser req, defer(errUser, user)

    err = errA or errE
    return next(err) if err

    voteData = _und.clone req.body
    voteData.ipAddr = req.header['x-real-ip'] or req.connection.remoteAddress
    voteData.browser = req.useragent.Browser
    voteData.os = req.useragent.OS
    voteData.lang = req.headers['accept-language']
    voteData.attrId = attr.serialize().id
    voteData.attrName = attr.serialize().name

    vote = new Vote voteData
    console.log vote

    entity.vote user, attr, vote, (err, voteTally) ->
        return res.status(500) if err
        res.send(voteTally)

###
# Entity Comment Section
###

# POST /entity/:id/comment
exports.addComment = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes, augReq)
    return next(errRes) if err
    _addComment(augReq, res, next)

_addComment = (req, res, next) ->
    valid = Comment.validateSchema req.body
    return res.status(400).json error: "Invalid input", input: req.body if not valid

    cleanedComment = Comment.fillMetaData Comment.deserialize req.body
    cleanedComment.username =
        if req.user then req.user.firstName + " " + req.user.lastName else "Anonymous"
    cleanedComment.location =
        req.header['x-real-ip'] or req.connection.remoteAddress

    discussionId = getDiscussionId req.params.id
    commentObjJson = JSON.stringify(cleanedComment)

    console.log commentObjJson

    await
        redis.lpush discussionId, commentObjJson, defer(err, result)

    return res.status(500).json error: "Unable to save comment" if err
    return res.json(cleanedComment) if result

# GET /entity/:id/comment
exports.listComment = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes, augReq)
    return errRes if err
    _listComment(augReq, res, next)

_listComment = (req, res, next) ->
    startIndex = req.params.start ? 0
    discussionId = getDiscussionId req.params.id

    await
        redis.lrange discussionId, startIndex, startIndex + 25, defer(err, comments)

    blobs = []
    for comment, ind in comments
        blobs[ind] = JSON.parse(comment)

    res.json(blobs)

# DELETE /entity/:id/comment
exports.delComment = (req, res, next) ->
    await hasPermission req, res, next, defer(err, errRes, augReq)
    return errRes if err
    _delComment(augReq, res, next)

_delComment = (req, res, next) ->
    res.status(503).json error: "Not Implemented"

###
# Entity Relation section
###

# TODO Fix permission here!
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

# TODO Fix permission here!
# POST /entity/:id/relation/entity/:id
exports.linkEntity = (req, res, next) ->
    await
        Entity.get req.params.srcId, defer(errSrc, srcEntity)
        Entity.get req.params.dstId, defer(errDst, dstEntity)

    return next(errSrc) if errSrc
    return next(errDst) if errDst

    relation = req.body

    if relation['src_dst']
        linkName  = Link.normalizeName(relation['src_dst']['name'])
        linkData = Link.deserialize(relation['src_dst']['data'])

        srcToDstLink = Utility.createLink srcEntity._node, dstEntity._node, linkName,
            linkData

    if relation['dst_src']
        linkName  = Link.normalizeName(relation['dst_src']['name'])
        linkData = Link.deserialize(relation['dst_src']['data'])

        dstToSrcLink = Utility.createLink dstEntity._node, srcEntity._node, linkName,
            linkData

    res.status(201).send()

# TODO Implement
exports.unlinkEntity = (req, res, next) ->
    res.status(503).json error: "Not Implemented"
@

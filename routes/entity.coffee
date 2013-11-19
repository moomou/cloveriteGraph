#entity.coffee
#Routes to CRUD entities
_und = require('underscore')
redis = require('../models/setup').db.redis

Logger = require('util')
Remote = require('../remote/remote')

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

EntityUtil = require('./entity/util')

Cypher = require('./cypher')
CypherBuilder = Cypher.CypherBuilder
CypherLinkUtil = Cypher.CypherLinkUtil

Response = require('./response')
ErrorDevMessage = Response.ErrorDevMessage

Utility = require('./utility')

getDiscussionId = (entityId) ->
    "entity:#{entityId}:discussion"

getRelationId = (path) ->
    splits = path.relationships[0]._data.self.split('/')
    splits[splits.length - 1]

hasPermission = (req, res, next, cb) ->
    ErrorResponse = Response.ErrorResponse(res)

    if isNaN req.params.id
        return cb true, ErrorResponse(400, ErrorDevMessage.missingParam("id")), null

    await
        Entity.get req.params.id, defer(errEntity, entity)
        Utility.getUser req, defer(errUser, user)

    err = errUser or errEntity

    return cb true, ErrorResponse(500, ErrorDevMessage.dbIssue()), null if err

    # Return authorized if not private and user is anonymous
    return cb false, null, req if not entity._node.data.private and not user

    await Utility.hasPermission user, entity, defer(err, authorized)

    if err
        return cb true, ErrorResponse(500, ErrorDevMessage.dbIssue()), null
    if not authorized
        return cb true, ErrorResponse(401, ErrorDevMessage.permissionIssue()), null

    # Returns a new shallow copy of req with user if authenticated
    reqWithUser = _und.extend _und.clone(req), user: user
    return cb false, null, reqWithUser

basicAuthentication = Utility.authCurry hasPermission


# GET /entity/search/
exports.search = (req, res, next) ->
    res.redirect "/#{Constants.API_VERSION}/search/?q=#{req.query['q']}"

# POST /entity - Please note, permission NOT required
exports.create = (req, res, next) ->
    await Utility.getUser req, defer(err, user)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    # anonymous user cannot create private entity
    req.body.private = false if not user
    console.log "Creating Entity"

    errs = []
    tagObjs = []

    # Create Entity and Tags
    await
        Entity.create req.body, defer(err, entity)

    await # Change once figure out tags
        for tagName, ind in entity.serialize().tags
            Tag.getOrCreate tagName, defer(errs[ind], tagObjs[ind])

    err = err or _und.find(errs, (err) -> err)
    return next(err) if err

    linkData = Link.fillMetaData({})

    # "tag" entity
    for tagObj, ind in tagObjs
        CypherLinkUtil.createLink tagObj._node, entity._node,
            Constants.REL_TAG,
            linkData,
            (err, rel) ->

        if user
            CypherLinkUtil.createLink user._node, tagObj._node,
                Constants.REL_TAG,
                linkData,
                (err, rel) ->

    # User is not defined for anonymous users
    if user
        await CypherLinkUtil.createMultipleLinks user._node,
            entity._node,
            [Constants.REL_CREATED, Constants.REL_ACCESS, Constants.REL_MODIFIED],
            linkData,
            defer(err, rels)

    await entity.serialize defer blob
    Response.OKResponse(res)(201, blob)

# GET /entity/:id
_show = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    if req.query['attr'] != "false"
        await
            EntityUtil.getEntityAttributes(entity, defer(attrBlobs))
        entityBlob = entity.serialize(null, attributes: attrBlobs)
    else
        entityBlob = entity.serialize(null, entityBlob)

    Response.OKResponse(res)(200, entityBlob)

exports.show = basicAuthentication _show

# PUT /entity/:id
_edit = (req, res, next) ->
    await Entity.put req.params.id, req.body, defer(err, entity)
    if err
        return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err.dbError
        return Response.ErrorResponse(res)(400, err.validationError) if err.validationError

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
        await
            CypherLinkUtil.hasLink tagObj._node,
                entity._node,
                Constants.REL_ATTRIBUTE,
                "all",
                defer(err, pathExists)

        if not pathExists
            CypherLinkUtil.createLink tagObj._node,
                entity._node,
                Constants.REL_TAG,
                linkData,
                (err, rel) ->

    await entity.serialize defer blob
    Response.OKResponse(res)(200, blob)

exports.edit = basicAuthentication _edit

# DELETE /entity/:id
_del = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    await entity.del defer(err)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    Response.OKResponse(res)(204)

exports.del = basicAuthentication _del

###
# Entity Use Section
###
_showUsers = (req, res, next) ->
    await Entity.get req.params.id, defer(err, entity)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    await
        entity._node.getRelationshipNodes {type: Constants.REL_MODIFIED, direction:'in'},
            defer(err, nodes)

    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err
    blobs = []

    for node, ind in nodes
        blobs[ind] = (new User node).serialize()

    Response.OKResponse(res)(200, blobs)

exports.showUsers = basicAuthentication _showUsers

###
# Entity Attribute Section
###

# GET /entity/:id/attribute
_listAttribute = (req, res, next) ->
    await Entity.get req.params.id, defer(errE, entity)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err.dbError

    await
        entity._node.getRelationshipNodes {type: Constants.REL_ATTRIBUTE, direction:'in'},
            defer(err, nodes)
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err.dbError

    rels = []
    blobs = []

    # TODO add error checking
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

    Response.OKResponse(res)(200, blobs)

exports.listAttribute = basicAuthentication _listAttribute

# POST /entity/:id/attribute
_addAttribute = (req, res, next) ->
    valid = Attribute.validateSchema req.body

    if not valid #TODO add message / update validation
        return Response.ErrorResponse(res)(400, ErrorDevMessage.dataValidationIssue())

    # Clean Data
    data = _und.clone req.body
    delete data['id']

    # Retrieve the 2 entities
    await
        Entity.get req.params.id, defer(errE, entity)
        Attribute.getOrCreate data, defer(errA, attr)

    err = errE or errA
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err.dbError

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
    await CypherLinkUtil.hasLink entity._node,
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
            await Remote.getJSONData(linkData.srcURL, defer(value))
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
        await Remote.getJSONData(linkData.srcURL, defer(value))
        linkData.value = value
        linkData.type =
            if not isNaN(value) then Constants.ATTR_NUMERIC else Constants.ATTR_REFERENCE

        linkData = Link.fillMetaData(linkData)
        await CypherLinkUtil.createLink attr._node,
            entity._node,
            Constants.REL_ATTRIBUTE,
            linkData,
            defer(err, rel)

        return next(err) if err

    Link.index(rel, linkData)

    await attr.serialize defer blob
    _und.extend blob, linkData: linkData
    Response.OKResponse(res)(200, blob)

exports.addAttribute = basicAuthentication _addAttribute

# TODO DELETE /entity/:eId/attribute/:aId
_delAttribute = (req, res, next) ->
    Response.ErrorResponse(res)(503, ErrorDevMessage.notImplemented())

exports.delAttribute = basicAuthentication _delAttribute

#GET /entity/:id/attribute/:id
_getAttribute =(req, res, next) ->
    ErrorResponse = Response.ErrorResponse(res)

    entityId = req.params.eId
    attrId = req.params.aId

    return ErrorResponse(400, ErrorDevMessage.missingParam("id")) if not attrId

    startendVal = Utility.getStartEndIndex(attrId,
        Constants.REL_ATTRIBUTE,
        entityId
    )

    await
        Link.find('startend', startendVal, defer(errLink, rel))
        Attribute.get attrId, defer(errAttr, attr)

    err = errLink || errAttr
    return ErrorResponse(500, ErrorDevMessage.dbIssue()) if err

    blob = {}
    await attr.serialize(defer(blob), entityId)

    _und.extend(blob, linkData: rel.serialize())
    Response.OKResponse(res)(200, blob)

exports.getAttribute = basicAuthentication _getAttribute

#PUT /entity/:id/attribute/:id
_updateAttributeLink = (req, res, next) ->
    ErrorResponse = Response.ErrorResponse(res)

    entityId = req.params.eId
    attrId = req.params.aId
    linkData = _und.clone(req.body['linkData'] || {})

    return ErrorResponse(400, ErrorDevMessage.missingParam("id")) if not attrId

    await
        Attribute.get attrId, defer(errAttr, attr)
        Link.put(linkData['id'], linkData, defer(errLink, rel))

    err = errAttr || errLink
    return ErrorResponse(500, ErrorDevMessage.dbIssue()) if err

    blob = attr.serialize()
    _und.extend blob, linkData: rel.serialize()

    Response.OKResponse(res)(200, blob)

exports.updateAttributeLink = basicAuthentication _updateAttributeLink

# POST /entity/:id/attribute/:id/vote
exports.voteAttribute = (req, res, next) ->
    await
        Entity.get req.params.eId, defer(errE, entity)
        Attribute.get req.params.aId, defer(errA, attr)
        Utility.getUser req, defer(errUser, user)

    err = errA or errE
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

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
        return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err
        Response.OKResponse(res)(200, voteTally)


## TODO Update the following to use new forms
###
# Entity Comment Section
###

# POST /entity/:id/comment
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

exports.addComment = basicAuthentication _addComment

# GET /entity/:id/comment
_listComment = (req, res, next) ->
    startIndex = req.params.start ? 0
    discussionId = getDiscussionId req.params.id

    await
        redis.lrange discussionId, startIndex, startIndex + 25, defer(err, comments)

    blobs = []
    for comment, ind in comments
        blobs[ind] = JSON.parse(comment)

    res.json(blobs)

exports.listComment = basicAuthentication _listComment

# DELETE /entity/:id/comment
_delComment = (req, res, next) ->
    res.status(503).json error: "Not Implemented"

exports.delComment = basicAuthentication _delComment

###
# Entity Relation section
###

# TODO Fix permission here!
# GET /entity/:id/relation
exports.listRelation = (req, res, next) ->
    entityId = req.params.id
    relType = req.params.relation

    query = CypherBuilder.getOutgoingRelsCypherQuery(entityId, relType)

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

        srcToDstLink = CypherLinkUtil.createLink srcEntity._node, dstEntity._node, linkName,
            linkData

    if relation['dst_src']
        linkName  = Link.normalizeName(relation['dst_src']['name'])
        linkData = Link.deserialize(relation['dst_src']['data'])

        dstToSrcLink = CypherLinkUtil.createLink dstEntity._node, srcEntity._node, linkName,
            linkData

    res.status(201).send()

# TODO Implement
exports.unlinkEntity = (req, res, next) ->
    res.status(503).json error: "Not Implemented"

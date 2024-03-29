# Entity Util
###
# Contains useful function for manipulating entity
###

_und = require('underscore')

Constants      = require('../../config').Constants
Logger         = require '../../util/logger'

Neo            = require '../../models/neo'

User           = require '../../models/user'
Entity         = require '../../models/entity'
Data           = require '../../models/data'
Attribute      = require '../../models/attribute'
Tag            = require '../../models/tag'
Link           = require '../../models/link'

Cypher         = require '../util/cypher'
CypherBuilder  = Cypher.CypherBuilder
CypherLinkUtil = Cypher.CypherLinkUtil

exports.getStartEndIndex = getStartEndIndex = (start, rel, end) ->
    "#{start}_#{rel}_#{end}"

exports.getEntityAttributes = (entity, cb) ->
    rels = []
    attrBlobs = []

    await
        entity._node.getRelationshipNodes({type: Constants.REL_ATTRIBUTE, direction:'in'},
            defer(err, nodes))
    return err if err

    await
        for node, ind in nodes
            startendVal = getStartEndIndex(node.id,
                Constants.REL_ATTRIBUTE,
                entity._node.id
            )

            Link.find('startend', startendVal, defer(err, rels[ind]))
            (new Attribute node).serialize(defer(attrBlobs[ind]), entity._node.id)

    for blob, ind in attrBlobs
        if rels[ind] and not rels[ind]._node.data.disabled
            linkData = linkData:rels[ind].serialize()
            _und.extend(blob, linkData)

    attrBlobs = _und(attrBlobs).filter (i) -> not _und(i.linkData).isEmpty()
    cb attrBlobs

exports.getEntityData = (entity, cb) ->
    await
        entity._node.getRelationshipNodes({type: Constants.REL_DATA, direction:'in'},
            defer(err, nodes))
    return err if err

    sDataBlob = []

    await
        for node, ind in nodes
            dataNode = new Data node
            sDataBlob.push dataNode.serialize()

    cb sDataBlob

exports.getEntityRanking = (entity, cb) ->

exports.addData = (entity, dataInputs, cb) ->
    errs  = []
    rels  = []
    datas = []

    for input, ind in dataInputs
        delete input.id

        value = null
        if input.dataType is Data.DataType.TIME_SERIES
            "" # Empty for now
        else if input.dataType is Data.DataType.FIELD
            if input.srcType is Data.SrcType.JSON
                await Remote.getJSONData input.srcUrl, defer(err, value)
            else if input.srcType is Data.SrcType.DOM
                await Remote.getDOMData input.srcUrl,
                    input.selector,
                    defer(err, value)

        if not input.value and value and not err
            input.value = value

        await Data.create input, defer err, datas[ind]
        data = datas[ind]

        continue if err

        await CypherLinkUtil.createLink data._node,
            entity._node,
            Constants.REL_DATA,
            {},
            defer(errs[ind], rels[ind])

    err = _und(errs).filter (err) -> err

    if _und(err).isEmpty()
        cb null, datas
    else
        cb errs, datas

THRESHOLD = 10
exports.cleanAttributes = (entity, cb) ->
    await
        entity._node.getRelationshipNodes({type: Constants.REL_ATTRIBUTE, direction:'in'},
            defer(err, nodes))
    return err if err

    cypher = ["START s=node({entityId}), e=node({attrId})",
        "MATCH s-[r:#{Constants.REL_VOTED}]-e",
        "RETURN COUNT(r) AS count;"]

    votesPerAttribute = []
    await
        for node, ind in nodes
            Neo.query null,
                cypher.join("\n"),
                {entityId: entity._node.id, attrId: node.id},
                defer(err, votesPerAttribute[ind])

    now = new Date().getTime() / 1000

    ###
    # The logic here should be if an attribute is over 10800 (3 days) old
    # and has no votes more than 2, remove link by marking as disabled
    ###
    Logger.debug "Votes per attribute: #{votesPerAttribute}"

    rels = {}
    await
        for vote, ind in votesPerAttribute
            vote = vote[0]
            if vote.count < THRESHOLD
                if now - nodes[ind].data.createdAt >= 10800
                    startendVal = getStartEndIndex(nodes[ind].id,
                        Constants.REL_ATTRIBUTE,
                        entity._node.id
                    )
                    Link.find('startend', startendVal, defer(err, rels[ind]))

    for rel, ind in _und(rels).values()
        rel._node.data.disabled = true
        rel.save()

    cb()

# Entity Util
###
# Contains useful function for manipulating entity
###

_und = require('underscore')

SchemaUtil = require('../../models/stdSchema')
Constants = SchemaUtil.Constants

Neo = require '../../models/neo'

User = require '../../models/user'
Entity = require '../../models/entity'
Data = require '../../models/data'
Attribute = require '../../models/attribute'
Tag = require '../../models/tag'
Link = require '../../models/link'

Utility = require '../utility'

exports.getEntityAttributes = (entity, cb) ->
    rels = []
    attrBlobs = []

    await
        entity._node.getRelationshipNodes({type: Constants.REL_ATTRIBUTE, direction:'in'},
            defer(err, nodes))
    return err if err

    await
        for node, ind in nodes
            startendVal = Utility.getStartEndIndex(node.id,
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
    console.log votesPerAttribute
    rels = {}
    await
        for vote, ind in votesPerAttribute
            vote = vote[0]
            if vote.count < THRESHOLD
                console.log "examining..."
                console.log(now - (nodes[ind].data.createdAt))
                if now - nodes[ind].data.createdAt >= 10800
                    startendVal = Utility.getStartEndIndex(nodes[ind].id,
                        Constants.REL_ATTRIBUTE,
                        entity._node.id
                    )
                    Link.find('startend', startendVal, defer(err, rels[ind]))

    for rel, ind in _und(rels).values()
        console.log rel
        rel._node.data.disabled = true
        console.log rel
        rel.save()

    cb()

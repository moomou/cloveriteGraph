# Entity Util
###
# Contains useful function for manipulating entity
###

_und = require('underscore')

SchemaUtil = require('../../models/stdSchema')
Constants = SchemaUtil.Constants

User = require('../../models/user')
Entity = require('../../models/entity')
Attribute = require('../../models/attribute')
Tag = require('../../models/tag')
Link = require('../../models/link')
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
        if rels[ind]
            linkData = linkData:rels[ind].serialize()
        else
            linkData = linkData:{}

        _und.extend(blob, linkData)

    console.log attrBlobs
    cb attrBlobs

exports.cleanAttributes = (entity, cb) ->
    await
        entity._node.getRelationshipNodes({type: Constants.REL_ATTRIBUTE, direction:'in'},
            defer(err, nodes))
    return err if err

    ###
    # The logic here should be if the attribute is over
    # if total attributeVote < day age of attribute and not over threshold
    #   remove link
    ###

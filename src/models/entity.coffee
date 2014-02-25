# entity.coffee
#
# Defines the fields of entity

Logger     = require 'util'
_und       = require 'underscore'

redis      = require('./setup').db.redis

Slug       = require '../util/slug'
SchemaUtil = require './stdSchema'
Neo        = require './neo'
Constants  = require('../config').Constants

INDEX_NAME = 'nEntity'
Indexes = [
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'name',
        INDEX_VALUE: ''
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'description',
        INDEX_VALUE: ''
    }
]

EntitySchema =
    # Cconfigured Values
    name                 : 'Name of entity'
    description          : ''
    type                 : ''
    tags                 : ['']

SchemaValidation =
    name        : SchemaUtil.required('string')
    description : SchemaUtil.optional('string')
    type        : SchemaUtil.optional('string')
    tags        : SchemaUtil.optional('array')

entityAttrPosVoteRedisKey = (id, aId) -> "entity:#{id}::attr:#{aId}::positive"
entityAttrNegVoteRedisKey = (id, aId) -> "entity:#{id}::attr:#{aId}::negative"

module.exports = class Entity extends Neo
    constructor: (@_node) ->
        super @_node
    getVoteByUser: (user = null, cb) ->
        if not user
            return cb(null, null)

        userId = user._node.id
        cypher = ["START s=node({entityId}), e=node({userId})",
            "MATCH (s)-[r:#{Constants.REL_VOTED}]-(e)",
            "RETURN r.attrId AS id, r.attrName AS name, r.tone AS vote ORDER BY r.attrId;"]

        await
            Neo.query null,
                cypher.join("\n"),
                {entityId: @_node.id, userId: userId},
                defer(err, results)

        return cb err, null if err
        cb null, results

    getVoteTally: (attr = null, cb) ->
        return cb null, null if not attr

        await
            redis.get entityAttrPosVoteRedisKey(@_node.id, attr._node.id),
                defer(errP, upVote)
            redis.get entityAttrNegVoteRedisKey(@_node.id, attr._node.id),
                defer(errN, downVote)

        return cb errP || errN, null if errP || errN

        voteTally =
            upVote: parseInt(upVote) or 0
            downVote: parseInt(downVote) or 0

        return cb null, voteTally

    vote: (user, attr, voteLink, cb) ->
        #Add a vote link between entity node and attr node
        #Records the vote in redis
        await
            @_node.createRelationshipTo attr._node,
                Constants.REL_VOTED,
                voteLink.data,
                defer(err, rel)

            if user
                voteLink.data.attribute = attr.serialize().name
                user._node.createRelationshipTo @_node,
                    Constants.REL_VOTED,
                    voteLink.data,
                    defer(err, rel)

        return cb err if err

        redis.incr "entity:#{@_node.id}::attr:#{attr._node.id}::#{voteLink.data.tone}"

        await
            redis.get entityAttrPosVoteRedisKey(@_node.id, attr._node.id),
                defer(errP, upVote)
            redis.get entityAttrNegVoteRedisKey(@_node.id, attr._node.id),
                defer(errN, downVote)

        return cb (errP || errN), null if errP or errN

        voteTally = {
            upVote: parseInt(upVote) or 0,
            downVote: parseInt(downVote) or 0
        }

        cb null, voteTally

    unlinkEntity: (other, relation, cb) ->
        @_node.getRelationships relation, (err, rels) ->
            return cb err if err
            reToOther = []
            reToOther.push rel for rel, i in rels when rel.end is other

            for rel in reToOther
                do (rel) ->
                    rel.del (err) -> cb err if err

###
Static Method
###
Entity.NodeType   = 'nEntity'
Entity.Name       = 'nEntity'
Entity.Indexes    = Indexes
Entity.INDEX_NAME = INDEX_NAME

Entity.validateSchema = (data) ->
    SchemaUtil.validate SchemaValidation, data

Entity.getSlugTitle = (data) ->
    Slug.slugify data.name

Entity.deserialize = (data) ->
    Neo.deserialize EntitySchema, data

Entity.create = (reqBody, cb) ->
    tags = reqBody.tags or []

    reqBody.private = false if not reqBody.user
    reqBody.tags    = _und.filter tags, (tag) -> tag and _und.isString(tag)
    reqBody.tags.push Constants.TAG_GLOBAL

    Neo.create Entity, reqBody, Indexes, cb

Entity.get = (id, cb) ->
    Neo.get Entity, id, cb

Entity.getOrCreate = (reqBody, cb) ->
    Logger.debug("Entity getOrCreate")
    Neo.getOrCreate Entity, reqBody, cb

Entity.put = (nodeId, reqBody, cb) ->
    tags = reqBody.tags or []
    reqBody.tags = _und.filter tags, (tag) -> tag and _und.isString(tag)
    Neo.put Entity, nodeId, reqBody, cb

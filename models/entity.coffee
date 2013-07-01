#entity.coffee
_und = require 'underscore'

Setup = require './setup'
Neo = require './neo'
redis = Setup.db.redis

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
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'description',
        INDEX_VALUE: ''
    }
]

EntitySchema = {
    imgURL: '',
    name: 'Name of entity',
    description: '',
    type: '',
    tags: ['']
}

module.exports = class Entity extends Neo
    constructor: (@_node) ->
        super @_node

    vote: (attr, voteLink, cb) ->
        #Add a vote link between entity node and attr node
        #Records the vote in redis
        await @_node.createRelationshipTo attr._node,
            voteLink.name,
            voteLink.data,
            defer(err, rel)
    
        return cb err if err

        redis.incr "entity:#{@_node.id}::attr:#{attr._node.id}::#{voteLink.data.type}"

        await redis.get "entity:#{@_node.id}::attr:#{attr._node.id}::pos", defer(err, upVote)
        await redis.get "entity:#{@_node.id}::attr:#{attr._node.id}::neg", defer(err, downVote)

        voteTally = {
            upVote: upVote or 0
            downVote: downVote or 0
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
Entity.Name = 'nEntity'
Entity.INDEX_NAME = INDEX_NAME

Entity.deserialize = (data) ->
    Neo.deserialize EntitySchema, data
 
Entity.create = (reqBody, cb) ->
    Neo.create Entity, reqBody, Indexes, cb

Entity.get = (id, cb) ->
    Neo.get Entity, id, cb

Entity.getOrCreate = (reqBody, cb) ->
    Neo.getOrCreate Entity, reqBody, cb

Entity.put = (nodeId, reqBody, cb) ->
    Neo.put Entity, nodeId, reqBody, cb

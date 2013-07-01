#attribute.coffee
#attribute model logic.
_und = require 'underscore'

Setup = require './setup'
Neo = require './neo'
redis = Setup.db.redis

INDEX_NAME = 'nAttribute'
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
        INDEX_KEY: 'type',
        INDEX_VALUE: ''
    }
]

AttributeSchema = {
    name: 'Name of attribute',
    description: '',
    type: '',    #data, quality, norm
    tone: 'pos', #defaults to pos
}

#Private constructor
module.exports = class Attribute extends Neo
    constructor: (@_node) ->
        super @_node

    serialize: (cb, entityId) ->
        if not entityId
            return super(cb, null)

        await
            redis.get "entity:#{entityId}::attr:#{@_node.id}::pos", defer(err, upVote)
            redis.get "entity:#{entityId}::attr:#{@_node.id}::neg", defer(err, downVote)

        voteTally = {
            upVote: upVote or 0
            downVote: downVote or 0
        }

        super cb, voteTally
###
Static Method
###
Attribute.Name = 'nAttribute'
Attribute.INDEX_NAME = INDEX_NAME

Attribute.deserialize = (data) ->
    Neo.deserialize AttributeSchema, data
 
Attribute.create = (reqBody, cb) ->
    Neo.create Attribute, reqBody, Indexes, cb

Attribute.get = (id, cb) ->
    Neo.get Attribute, id, cb
 
Attribute.getOrCreate = (reqBody, cb) ->
    Neo.getOrCreate Attribute, reqBody, cb

Attribute.put = (nodeId, reqBody, cb) ->
    Neo.put Attribute, nodeId, reqBody, cb

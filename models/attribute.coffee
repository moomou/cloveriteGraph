#attribute.coffee
#attribute model logic.
_und = require 'underscore'

Setup = require './setup'
Neo = require './neo'
redis = Setup.db.redis

#contants
INDEX_NAME = 'node'
INDEX_KEY = 'type'
INDEX_VAL = 'attribute'

AttributeSchema = {
    name: 'Name of attribute',
    description: '',
    type: '',
    tags: [''],
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
Attribute.deserialize = (data) ->
    Neo.deserialize AttributeSchema, data
 
Attribute.create = (reqBody, cb) ->
    index = {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: INDEX_KEY,
        INDEX_VAL: INDEX_VAL
    }
    Neo.create Attribute, reqBody, index, cb

Attribute.get = (id, cb) ->
    Neo.get Attribute, id, cb
 
Attribute.getOrCreate = (reqBody, cb) ->
    if reqBody['id']
        return Attribute.get reqBody['id'], cb
    else
        return Attribute.create reqBody, cb

Attribute.put = (nodeId, reqBody, cb) ->
    Neo.put Attribute, nodeId, reqBody, cb

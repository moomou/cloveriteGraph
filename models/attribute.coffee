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
    value: '',      #data value, could be 3 types: string, number, and boolean
    dataLink: '',   #link to data source
    description: '',#describing what this attribute is
    type: '',       #data, quality, norm
    tone: 'positive'     #defaults to pos
}

#Private constructor
module.exports = class Attribute extends Neo
    constructor: (@_node) ->
        super @_node

    serialize: (cb, entityId) ->
        if not entityId
            return super(cb, null)

        await
            redis.get "entity:#{entityId}::attr:#{@_node.id}::positive", defer(err, upVote)
            redis.get "entity:#{entityId}::attr:#{@_node.id}::negative", defer(err, downVote)

        voteTally = {
            upVote: parseInt(upVote) or 0
            downVote: parseInt(downVote) or 0
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

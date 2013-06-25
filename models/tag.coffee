#tag.coffee
#tag model logic.
_und = require 'underscore'

Setup = require './setup'
Neo = require './neo'
redis = Setup.db.redis

INDEX_NAME = 'tag'

Indexes = [
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'name',
        INDEX_VALUE: ''
    }
]

# $ for general tag, 
# # for specific item tag
TagSchema = {
    name: 'Name of Tag',
}

module.exports = class Tag extends Neo
    constructor: (@_node) ->
        super @_node

###
Static Method
###
Tag.Name = 'TAG'
Tag.INDEX_NAME = 'tag'

Tag.deserialize = (data) ->
    Neo.deserialize TagSchema, data
 
Tag.create = (reqBody, cb) ->
    Neo.create Tag, reqBody, Indexes, cb

Tag.get = (id, cb) ->
    Neo.get Tag, id, cb

Tag.getOrCreate = (tagName, cb) ->
    Neo.getOrCreate Tag, name:tagName, cb

Tag.put = (nodeId, reqBody, cb) ->
    Neo.put Tag, nodeId, reqBody, cb

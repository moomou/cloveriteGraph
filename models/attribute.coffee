#attribute.coffee
#attribute model logic.
_und = require 'underscore'
Neo = require './neo'
Meta = require './meta'

#contants
INDEX_NAME = 'node'
INDEX_KEY = 'type'
INDEX_VAL = 'attribute'
REL_RESOURCE = '_resource'

AttributeSchema = {
    name: 'Name of attribute',
    type: '',
    tags: [''],
    version: 0,
    private: false,
}

#Private constructor
module.exports = class Attribute extends Neo
    constructor: (@_node) ->
        super @_node
###
Static Method
###
Attribute.deserialize = (data) ->
    _und.defaults data, AttributeSchema
    return data
 
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

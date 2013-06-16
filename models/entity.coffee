#entity.coffee
_und = require 'underscore'
Neo = require './neo'
Meta = require './meta'

#contants
INDEX_NAME = 'node'
INDEX_KEY = 'type'
INDEX_VAL = 'entity'

REL_LOCATION = '_location'
REL_AWARD = '_award'
REL_ATTRIBUTE = '_attribute'
REL_PARENT = '_parent'
REL_CHILD = '_child'
REL_CONTAINER = '_container'
REL_RESOURCE = '_resource'

EntitySchema = {
    "name": "Name of entity",
    "type": "",
    "tags": [""],
    "version": 0,
    "private": false
}

module.exports = class Entity extends Neo
    constructor: (@_node) ->
        super @_node

    vote: (attr, vote, cb) ->

    unlinkEntity: (other, relation, cb) ->
        @_node.getRelationships relation, (err, rels) ->
            return cb err if err
            reToOther = []
            reToOther.push rel for rel, i in rels when rel.end is other

            for rel in reToOther
                do (rel) ->
                    rel.del (err) -> cb err if err

    getAttribute: (cb) ->
        query = [
            'START user=node({userId})',
            'MATCH (user)<-[:REL_ATTRIBUTE]-(attributes)',
            'RETURN attributes, count(attributes)'
        ].join('\n').replace('REL_ATTRIBUTE', REL_ATTRIBUTE)

        params = {
            userId: @id
        }

        Neo.query(Entity, query, params, cb)

###
Static Method
###
Entity.deserialize = (data) ->
    _und.defaults data, EntitySchema
    return data
 
Entity.create = (reqBody, cb) ->
    index = {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: INDEX_KEY,
        INDEX_VAL: INDEX_VAL
    }
    Neo.create Entity, reqBody, index, cb

Entity.get = (id, cb) ->
    Neo.get Entity, id, cb
    
Entity.put = (nodeId, reqBody, cb) ->
    Neo.put Entity, nodeId, reqBody, cb

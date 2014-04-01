# ranking coffee
#
# user -ranking_link-> rank -> E1, E2
#       {
#       }
#                      {
#                       rankId: #search term or specific tag user sets
#                      }

_und       = require 'underscore'

Logger     = require '../util/logger'
Slug       = require '../util/slug'
Neo        = require './neo'
redis      = require('./setup').db.redis

SchemaUtil = require './stdSchema'

INDEX_NAME = 'nCollection'
Indexes = [
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'name',
        INDEX_VALUE: ''
    }
]

CollectionSchema =
    createdBy      : 'username'
    private        : true
    name           : 'New Collection'
    collection     : [-1]
    shareToken     : ''
    description    : ''
    collectionType : 'list' #list or ranking

SchemaValidation = {
}

#Private constructor
module.exports = class Collection extends Neo
    constructor: (@_node) ->
        super @_node

###
Static Method
###
Collection.Name = 'nCollection'
Collection.INDEX_NAME = INDEX_NAME
Collection.Indexes = Indexes

Collection.validateSchema = (data) ->
    SchemaUtil.validate SchemaValidation, data

Collection.getSlugTitle = (data) ->
    Slug.slugify data.name

Collection.deserialize = (data) ->
    Neo.deserialize CollectionSchema, data

Collection.create = (reqBody, cb) ->
    Neo.create Collection, reqBody, Indexes, cb

Collection.get = (id, cb) ->
    Neo.get Collection, id, cb

Collection.getOrCreate = (reqBody, cb) ->
    Logger.debug("Collection getOrCreate")
    Neo.getOrCreate Collection, reqBody, cb

Collection.put = (nodeId, reqBody, cb) ->
    Neo.put Collection, nodeId, reqBody, cb

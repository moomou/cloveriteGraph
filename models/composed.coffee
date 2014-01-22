#attribute.coffee
#attribute model logic.

_und = require 'underscore'
Logger = require 'util'

Setup = require './setup'
Neo = require './neo'
redis = Setup.db.redis

SchemaUtil = require './stdSchema'

INDEX_NAME = 'nComposed'
Indexes = [
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'title',
        INDEX_VALUE: ''
    }
]

#Private constructor
module.exports = class Composed extends Neo
    _Schema =
        title: ''
        profileIconUrl: ''
        authorName: ['']
        authorProfileUrl: ['']
        tags: ['']
        dataChain: ['']
        entityId: ['']

    _SchemaValidation = {}

    constructor: (@_node) ->
        super @_node
    
    @INDEX_NAME = INDEX_NAME
    @Name = INDEX_NAME
    @Indexes = Indexes

    @validateSchema = (data) ->
        SchemaUtil.validate _SchemaValidation, data

    @deserialize = (data) ->
        Neo.deserialize _Schema , data

    @create = (reqBody, cb) ->
        Neo.create Composed, reqBody, @Indexes, cb

    @get = (id, cb) ->
        Neo.get Composed, id, cb

    @getOrCreate = (reqBody, cb) ->
        Neo.getOrCreate Composed, reqBody, cb

    @put = (nodeId, reqBody, cb) ->
        Neo.put Composed, nodeId, reqBody, cb

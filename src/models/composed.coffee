#attribute.coffee
#attribute model logic.

Logger     = require 'util'
_und       = require 'underscore'

redis      = require('./setup').db.redis

Slug       = require '../util/slug'
Neo        = require './neo'
SchemaUtil = require './stdSchema'

INDEX_NAME = 'nComposed'

Indexes    = [
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
    @Name       = INDEX_NAME
    @Indexes    = Indexes

    @validateSchema = (data) ->
        SchemaUtil.validate _SchemaValidation, data

    @getSlugTitle = (data) ->
        Slug.slugify data.name

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

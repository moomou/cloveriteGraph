#attribute.coffee
#attribute model logic.

_und       = require 'underscore'

redis      = require('./setup').db.redis

Logger     = require '../util/logger'
Slug       = require '../util/slug'
Neo        = require './neo'
SchemaUtil = require './stdSchema'

INDEX_NAME = 'nAttribute'
Indexes = [
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'name',
        INDEX_VALUE: ''
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'tone',
        INDEX_VALUE: ''
    }
]

AttributeSchema =
    name        : 'Attribute Name'
    description : ''
    tone        : 'positive' #defaults to positive

SchemaValidation =
    name: SchemaUtil.required 'string',
    tone: SchemaUtil.optional 'string'

#Private constructor
module.exports = class Attribute extends Neo
    constructor: (@_node) ->
        super @_node

    # Takes an entity id to retrieve vote in redis
    serialize: (cb, entityId) ->
        Logger.debug "Serialize attr: #{entityId}"
        if not entityId
            return super(cb, null)

        await
            redis.get "entity:#{entityId}::attr:#{@_node.id}::positive", defer(err, upVote)
            redis.get "entity:#{entityId}::attr:#{@_node.id}::negative", defer(err, downVote)

        voteTally =
            upVote   : parseInt(upVote) or 0
            downVote : parseInt(downVote) or 0

        Logger.debug "VoteTally: #{voteTally.upVote}"
        super cb, voteTally

###
# Static Method
###

Attribute.Name       = 'nAttribute'
Attribute.INDEX_NAME = INDEX_NAME
Attribute.Indexes    = Indexes

Attribute.getSlugTitle = (data) ->
    Slug.slugify data.name

Attribute.validateSchema = (data) ->
    SchemaUtil.validate SchemaValidation, data

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

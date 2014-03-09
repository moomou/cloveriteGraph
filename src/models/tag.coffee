#tag.coffee

_und       = require 'underscore'

redis      = require('./setup').db.redis

Logger     = require '../util/logger'
Slug       = require '../util/slug'
Neo        = require './neo'
SchemaUtil = require './stdSchema'

INDEX_NAME = 'nTag'

Indexes = [
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'name',
        INDEX_VALUE: ''
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'slug',
        INDEX_VALUE: ''
    }
]

TagSchema =
    name: 'Name of Tag'

SchemaValidation =
    name: SchemaUtil.required('string')

module.exports = class Tag extends Neo
    constructor: (@_node) ->
        super @_node

Tag.Name       = 'nTag'
Tag.INDEX_NAME = INDEX_NAME
Tag.Indexes    = Indexes

Tag.getSlugTitle = (data) ->
    Slug.slugify data.name

Tag.deserialize = (data) ->
    Neo.deserialize TagSchema, data
 
Tag.create = (reqBody, cb) ->
    Neo.create Tag, reqBody, Indexes, cb

Tag.get = (id, cb) ->
    Neo.get Tag, id, cb

Tag.getOrCreate = (tagName, cb) ->
    Logger.debug "Tag getOrCreate cb: #{cb}"
    Neo.getOrCreate Tag, name: tagName, cb

Tag.put = (nodeId, reqBody, cb) ->
    Neo.put Tag, nodeId, reqBody, cb

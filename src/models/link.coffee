#link.coffee

_und      = require 'underscore'
redis     = require('./setup').db.redis

Logger     = require '../util/logger'
Slug      = require '../util/slug'
Constants = require('../config').Constants
Neo       = require './neo'

INDEX_NAME = 'rLink'
Indexes = [
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'startend',
        INDEX_VALUE: ''
    }
]

LinkSchema =
    # configured value
    # calculated value
    disabled: false
    veracity: 0      #whehter this link is factual or not

SchemaValidation = {}

module.exports = class Link extends Neo
    constructor: (@_node) ->
        super @_node

###
Static Method
###
Link.Name = 'rLink'
Link.INDEX_NAME = INDEX_NAME

Link.getSlugTitle = (data) ->
    if data.name then Slug.slugify data.name else ""

Link.deserialize = (data) ->
    Neo.deserialize(LinkSchema, data)

Link.normalizeName = (name) ->
    "_#{name.toUpperCase()}"

Link.normalizeData = (linkData) ->
    Link.deserialize(linkData)
    #Link.fillMetaData

Link.index = (rel, reqBody, cb = null) ->
    Neo.index(rel, Indexes, reqBody, cb)

Link.fillMetaData = (linkData) ->
    linkData = _und.clone(linkData)
    _und.extend(linkData, Neo.MetaSchema)

    linkData.createdAt =
        linkData.modifiedAt = new Date().getTime() / 1000
    linkData.version += 1

    linkData

Link.find = (key, value, cb) ->
    Neo.findRel(Link, Link.INDEX_NAME, key, value, cb)

Link.get = (id, cb) ->
    Neo.getRel(Link, id, cb)

Link.put = (relId, reqBody, cb) ->
    Neo.put Link, relId, reqBody, cb

Link.create = (reqBody, cb) ->
    linkName = Link.normalizeName(reqBody['name'])
    linkData = Link.normalizeData(reqBody['data'])

    res = {
        name: linkName,
        data: linkData
    }

    if cb
        cb(null, res)
    else
        res

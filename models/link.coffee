#link.coffee
_und = require 'underscore'

Setup = require './setup'
Neo = require './neo'
redis = Setup.db.redis
db = Setup.db

StdSchema = require './stdSchema'
Contants = StdSchema.Contants

INDEX_NAME = 'rLink'

Indexes = [
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'startend',
        INDEX_VALUE: ''
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'srcURL',
        INDEX_VALUE: ''
    }
]

LinkSchema = {
    # configured value
    srcURL: '',      #link to data source
    description: '', #describing what this attribute is

    # calculated value
    value: '',       #data value: string, number, and boolean
    veracity: 0      #whehter this link is factual or not
}

module.exports = class Link extends Neo
    constructor: (@_node) ->
        super @_node

###
Static Method
###
Link.Name = 'rLink'
Link.INDEX_NAME = INDEX_NAME

Link.deserialize = (data) ->
    Neo.deserialize(LinkSchema, data)

Link.normalizeName = (name) ->
    "_#{name.toUpperCase()}"

Link.normalizeData = (linkData) ->
    Link.fillMetaData Link.deserialize(linkData)

Link.index = (rel, reqBody, cb = null) ->
    Neo.index(rel, Indexes, reqBody, cb)

Link.fillMetaData = (linkData) ->
    linkData = _und.clone(linkData)
    _und.extend(linkData, Neo.MetaSchema)

    linkData.createdAt =
        linkData.modifiedAt = new Date().getTime() / 1000

    linkData.version += 1
    return linkData

Link.find = (key, value, cb) ->
    Neo.findRel(Link, Link.INDEX_NAME, key, value, cb)

Link.get = (id, cb) ->
    Neo.getRel(Link, id, cb)

Link.put = (relId, reqBody, cb) ->
    data = Link.deserialize(reqBody)
    Neo.put(Link, relId, data, cb)

Link.create = (reqBody, cb) ->
    linkName  = Link.normalizeName(reqBody['name'])
    linkData = Link.normalizeData(reqBody['data'])

    res = {
        name: linkName,
        data: linkData
    }

    cb(null, res) if cb
    res

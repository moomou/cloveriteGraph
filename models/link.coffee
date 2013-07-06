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
    srcURL: '',   #link to data source
    description: '',#describing what this attribute is
    value: '',      #data value, could be 3 types: string, number, and boolean

    veracity: 0,      #whehter this link is factual or not
    startend: ''      #for index use
}

module.exports = class Link extends Neo
    constructor: (@_node) ->
        super @_node

###
Static Method
###
Link.Name = 'rLink'
Link.INDEX_NAME = INDEX_NAME

Link.normalizeName = (name) ->
    "_#{name.toUpperCase()}"

Link.cleanData = (data) ->
    validKeys = _und.keys(LinkSchema)
    _und.defaults data, LinkSchema
    data

Link.index = (rel, reqBody, cb = null) ->
    Neo.index(rel, Indexes, reqBody, cb)

Link.find = (key, value, cb) ->
    Neo.findRel(Link, Link.INDEX_NAME, key, value, cb)

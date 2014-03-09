# rank.coffee
#
# For managing rank 

_und      = require 'underscore'

Logger    = require '../util/logger'
Slug      = require '../util/slug'
Constants = require('../config').Constants
Neo       = require './neo'

INDEX_NAME = 'rRank'
Indexes = [
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'rank',
        INDEX_VALUE: ''
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'rankingName',
        INDEX_VALUE: ''
    }
]

RankSchema =
    rank: -1
    rankingName: 'New Ranking'

module.exports = class Rank extends Neo
    constructor: (@_node) ->
        super @_node

###
Static Method
###
Rank.Name = 'rRank'
Rank.INDEX_NAME = INDEX_NAME

Rank.getSlugTitle = (data) ->
    if data.name then Slug.slugify data.name else ""

Rank.deserialize = (data) ->
    Neo.deserialize RankSchema, data

Rank.index = (rel, reqBody, cb = null) ->
    Neo.index(rel, Indexes, reqBody, cb)

Rank.find = (key, value, cb) ->
    Neo.findRel Rank, Rank.INDEX_NAME, key, value, cb

Rank.get = (id, cb) ->
    Neo.getRel Rank, id, cb

Rank.put = (relId, reqBody, cb) ->
    Neo.putRel Rank, relId, reqBody, cb

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

INDEX_NAME = 'nRanking'
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

RankingSchema =
    private: true
    name: 'New Ranking'
    ranks: [-1]
    tone: 'positive'  #defaults to positive
    createdBy: 'username'
    shareToken: ''

SchemaValidation = {
}

#Private constructor
module.exports = class Ranking extends Neo
    constructor: (@_node) ->
        super @_node

###
Static Method
###
Ranking.Name = 'nRanking'
Ranking.INDEX_NAME = INDEX_NAME
Ranking.Indexes = Indexes

Ranking.validateSchema = (data) ->
    SchemaUtil.validate SchemaValidation, data

Ranking.getSlugTitle = (data) ->
    Slug.slugify data.name

Ranking.deserialize = (data) ->
    Neo.deserialize RankingSchema, data

Ranking.create = (reqBody, cb) ->
    Neo.create Ranking, reqBody, Indexes, cb

Ranking.get = (id, cb) ->
    Neo.get Ranking, id, cb

Ranking.getOrCreate = (reqBody, cb) ->
    Logger.debug("Ranking getOrCreate")
    Neo.getOrCreate Ranking, reqBody, cb

Ranking.put = (nodeId, reqBody, cb) ->
    Neo.put Ranking, nodeId, reqBody, cb

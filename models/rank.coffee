# rank.coffee

_und = require 'underscore'
StdSchema = require './stdSchema'
Contants = StdSchema.Contants

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

RankSchema = {
    rank: -1,
    rankingName: 'New Ranking',
}

module.exports = class Rank
    constructor: (voteData) ->
        @name = Constants.REL_RANK

        data = _und.clone voteData
        _und.defaults data, RankSchema
        _und.pick data, (_und.keys RankSchema)

        @data = data

        if not @data.time
            @data.time = '' + new Date().getTime()

###
Static Method
###
Rank.Name = 'rRank'
Rank.INDEX_NAME = INDEX_NAME

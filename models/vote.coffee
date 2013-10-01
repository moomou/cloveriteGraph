#vote.coffee

_und = require 'underscore'
StdSchema = require './stdSchema'
Contants = StdSchema.Contants

INDEX_NAME = 'rVote'
Indexes = [
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'user',
        INDEX_VALUE: ''
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'os',
        INDEX_VALUE: ''
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'lang',
        INDEX_VALUE: ''
    }
]

VoteSchema = {
    attrId: '',     #attr voted on
    tone: '',       #vote type: pos, neg
    user: '',       #username or unknown
    time: '',       #timestamp when vote was registered
    ipAddr: '',     #ip address of the vote
    lang: '',       #language of the user
    browser: '',      #browser type
    os: '',
    rating: 0,      #numerical value for rating - unused right now
}

module.exports = class Vote
    constructor: (voteData) ->
        @name = Contants.REL_VOTED

        data = _und.clone voteData
        _und.defaults data, VoteSchema
        _und.pick data, (_und.keys VoteSchema)

        @data = data

        if not @data.time
            @data.time = '' + new Date().getTime()

###
Static Method
###
Vote.Name = 'rVote'
Vote.INDEX_NAME = INDEX_NAME

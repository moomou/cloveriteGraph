#vote.coffee

_und = require 'underscore'

SchemaUtil = require './stdSchema'
Constants = SchemaUtil.Constants

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
    attrName: '',   #attr voted on
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
        @name = Constants.REL_VOTED

        console.log "Cleaning..."
        data = _und.clone voteData
        data = _und.defaults data, VoteSchema
        data = _und.pick data, _und.keys VoteSchema

        console.log data

        @data = data

        if not @data.time
            @data.time = '' + new Date().getTime()

###
Static Method
###
Vote.Name = 'rVote'
Vote.INDEX_NAME = INDEX_NAME

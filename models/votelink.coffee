_und = require 'underscore'
Contants = require './stdSchema'

VoteSchema = {
    type: '',       #vote type: pos, neg
    ipAddr: '',     #ip address of the vote
    user: '',       #username or unknown
    time: '',       #timestamp when vote was registered
    lang: '',       #language of the user
    agent: '',      #browser type
    rating: 0,      #numerical value for rating - unused right now
}

module.exports = class VoteLink
    constructor: (vote) ->
        data = VoteSchema
        @data = _und.defaults vote, VoteSchema
        @name = Contants.REL_VOTE

        if not @data.time
            @data.time = new Date().getTime() / 1000

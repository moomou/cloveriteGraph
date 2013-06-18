_und = require 'underscore'
StdSchema = require './stdSchema'
Contants = StdSchema.Contants

VoteSchema = {
    type: '',       #vote type: pos, neg
    user: '',       #username or unknown
    time: '',       #timestamp when vote was registered
    ipAddr: '',     #ip address of the vote
    lang: '',       #language of the user
    browser: '',      #browser type
    os: '',
    rating: 0,      #numerical value for rating - unused right now
}

module.exports = class VoteLink
    constructor: (vote) ->
        @data = _und.clone vote
        @name = '_VOTE'

        _und.defaults @data, VoteSchema

        if not @data.time
            @data.time = '' + new Date().getTime()

#comment.coffee
_und = require 'underscore'
Logger = require 'util'

Setup = require './setup'
Neo = require './neo'

CommentSchema = {
    comment: '',
    userId: '', # unique id that identify user; randomId if not authenticated
    location: ''  # unique ip address
}

module.exports =
    deserialize: (data) ->
        Neo.deserialize CommentSchema, data
    fillMetaData: (data) ->
        Neo.fillMetaData data

#comment.coffee
_und = require 'underscore'
Logger = require 'util'

Setup = require './setup'
Neo = require './neo'

SchemaUtil = require './stdSchema'

CommentSchema = {
    # Configured Values
    comment: '',

    # Calculated Values
    username: '', # unique id that identify user; anonymous if not authenticated
    location: ''  # unique ip address
}

SchemaValidation = {
    comment: SchemaUtil.required('string')
}

module.exports =
    validateSchema: (data) ->
        SchemaUtil.validate SchemaValidation, data
    deserialize: (data) ->
        Neo.deserialize CommentSchema, data
    fillMetaData: (data) ->
        Neo.fillMetaData data

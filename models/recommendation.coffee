#recommendation.coffee

_und = require 'underscore'
Logger = require 'util'

Setup = require './setup'
Neo = require './neo'

SchemaUtil = require './stdSchema'

RecommendationSchema = {
    # Configured Values
    to: '',        # unique username
    from: '',      # author
    content: [''], # tags for the user to search for
}

SchemaValidation = {
}

module.exports =
    validateSchema: (data) ->
        SchemaUtil.validate SchemaValidation, data
    deserialize: (data) ->
        Neo.deserialize RecommendationSchema, data
    fillMetaData: (data) ->
        Neo.fillMetaData data

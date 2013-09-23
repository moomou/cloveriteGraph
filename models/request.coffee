#request.coffee

_und = require 'underscore'
Logger = require 'util'

Setup = require './setup'
Neo = require './neo'

SchemaUtil = require './stdSchema'

RequestSchema = {
    to: '',
    from: '',
    request: ''
}

SchemaValidation = {
}

module.exports =
    validateSchema: (data) ->
        SchemaUtil.validate SchemaValidation, data
    deserialize: (data) ->
        Neo.deserialize RequestSchema, data
    fillMetaData: (data) ->
        Neo.fillMetaData data
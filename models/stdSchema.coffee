_und = require('underscore')

exports.Constants = Constants = {
    INDEX_NAME: 'node',
    INDEX_KEY: 'type',
    INDEX_VAL: 'entity',

    REL_LOCATION: '_LOCATION',
    REL_VOTE: '_VOTE',
    REL_AWARD: '_AWARD',
    REL_ATTRIBUTE: '_ATTRIBUTE',
    REL_PARENT: '_PARENT',
    REL_CHILD: '_CHILD',
    REL_CONTAINER: '_CONTAINER',
    REL_RESOURCE: '_RESOURCE',
    REL_META: '_META'
}

###
    Relationship Schema
###
exports.ErrorResponse = class ErrorResponse
    constructor: (
        @msg,       #message describing the problem
        @fix        #potential fix
    ) ->
    serialize: ->
        return {
            message: @msg,
            solution: @fix
        }

class AttrLink
    constructor: (
    ) ->

class Link
    constructor: (
        @linkName
        @linkData
    ) ->

_und = require('underscore')

exports.Constants = Constants = {
    # Generic Relation
    REL_LOCATION: '_LOCATION',
    REL_AWARD: '_AWARD',
    REL_ATTRIBUTE: '_ATTRIBUTE',
    REL_PARENT: '_PARENT',
    REL_CHILD: '_CHILD',
    REL_CONTAINER: '_CONTAINER',
    REL_RESOURCE: '_RESOURCE',

    REL_TAG: '_TAG',

    REL_ACCESS: '_ACCESS',
    REL_CREATED: '_CREATED',

    # Action 
    # User to Entity, Attribute, or User
    REL_VOTED: '_VOTED',
    REL_COMMENTED: '_COMMENTED',

    # this is a generic relationship
    # that indicate a user has done
    # one of the following
    # 1) Voted
    # 2) Created
    # 3) Modified (ie put)
    # 4) Commented
    REL_MODIFIED: '_MODIFIED',

    # Attr Type
    ATTR_NUMERIC: "attr_numeric",
    ATTR_REFERENCE: "attr_ref"
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

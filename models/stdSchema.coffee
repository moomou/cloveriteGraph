_und = require('underscore')
Hashids = require("hashids")

_validator = (valid, validate, input) ->
    return [false, input] if not valid
    valid = validate input
    [valid, input]

Validators = {
    string: (state, input) -> _validator(state, _und.isString, input),
    number: (state, input) -> _validator(state, _und.isNumber, input),
    array: (state, input) -> _validator(state, _und.isArray, input),
}

validationSchema = (required, validator) ->
    if not _und.isFunction(validator)
        validator = Validators[(_und.values validator)[0]]
    required: required, validator: validator

# TODO improve
# Does not check for required vs optional
exports.validate = (schemaValidation, input) ->
    result = _und.map schemaValidation, (value, key) ->
        console.log key
        if value.required
            console.log "REQUIRED"
            return false if not input[key]
            [valid, _] = value.validator(true, input[key])
            valid
        else if key in input
            console.log "OPTIONAL"
            [valid, _] = value.validator(true, input[key])
            valid
        else
            true
    console.log result
    return false if _und.contains(result, false)
    console.log "VALID"
    return true

exports.required = () ->
    validationSchema true, arguments

exports.optional= () ->
    validationSchema false, arguments

exports.Constants = Constants = {
    API_VERSION: 'v0',
    TAG_GLOBAL: '#__global__',

    # Generic Relation
    REL_LOCATION: '_LOCATION',
    REL_AWARD: '_AWARD',
    REL_ATTRIBUTE: '_ATTRIBUTE',
    REL_COMPOSED: '_COMPOSED',
    REL_DATA: '_DATA',
    REL_FORKED: '_FORKED',
    REL_PARENT: '_PARENT',
    REL_CHILD: '_CHILD',
    REL_CONTAINER: '_CONTAINER',
    REL_RESOURCE: '_RESOURCE',

    REL_TAG: '_TAG',
    REL_ACCESS: '_ACCESS',
    REL_RANK: '_RANK',
    REL_RANKING: '_RANKING',

    # Action
    # User to Entity, Attribute, or User
    REL_VOTED: '_VOTED',
    REL_COMMENTED: '_COMMENTED',
    REL_CREATED: '_CREATED',

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

exports.RedisKey = {
    shareTokens: "shareTokens",
}

exports.Security = {
    hashids: new Hashids("Trust.Aspire.Succeed.Profit", 10)
}

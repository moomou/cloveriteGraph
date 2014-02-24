_und    = require 'underscore'
Hashids = require 'hashids'

_validator = (valid, validate, input) ->
    return [false, input] if not valid
    valid = validate input
    [valid, input]

Validators =
    string: (state, input) -> _validator(state, _und.isString, input)
    number: (state, input) -> _validator(state, _und.isNumber, input)
    array: (state, input) -> _validator(state, _und.isArray, input)

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

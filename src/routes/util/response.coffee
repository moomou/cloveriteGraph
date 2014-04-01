# Response.coffee
###
# Responsible for delivering user facing data
###

_und = require('underscore')

DEFAULT_RESPONSE = {
    success: true,      # indicate whether the response was successful
    payload: null,      # data payload
    httpCode: null,     # HTTP code of the response
    error: null,        # null if no error, else an obj containing details
    next: null,         # link to next data
    prev: null,         # link to prev data
}

MessageGen = {
    '400': "Please check all required fields are provided and correct.",
    '500': "Oops. That didn't work. Please try again. If the problem persists, please notify us.",
    '403': "Permission denied"
}

DevMessageGenerator =
    customMsg: (msg) -> msg
    missingParam: (paramName) -> "Missing required field: #{paramName}."
    dbIssue: -> "Connection problems with internal db. Please try again later."
    notFound: -> "Requested resource does not exist."
    permissionIssue: -> "The user does not have permission."
    dataValidationIssue: (msg)-> "Data issue: #{msg}"
    notImplemented: -> "Not Implemented."

DOC_LINK = {
}

createErrorDetailObj = (devMsg, msg, docLink) -> {
    message: msg or null,
    devMessage: devMsg or msg or null,
    documentation: docLink or null
}

errorMessage = (httpCode) ->
    MessageGen[httpCode.toString()]

exports.ErrorDevMessage = DevMessageGenerator

exports.ErrorResponse = (res) -> (httpCode, devMsg, docLink) ->
    response          = _und.clone DEFAULT_RESPONSE
    response.success  = false
    response.httpCode = httpCode
    response.error    = createErrorDetailObj devMsg, errorMessage(httpCode), docLink
    res.status(httpCode).json(response)

exports.OKResponse = (res) -> (httpCode, payload, next, prev) ->
    response          = _und.clone DEFAULT_RESPONSE
    response.payload  = payload
    response.httpCode = httpCode
    response.next     = next
    response.prev     = prev
    res.status(httpCode).json(response)

exports.JSResponse = (res) -> (httpCode, payload, next, prev) ->
    res.setHeader "Content-Type", "text/javascript"
    res.status(httpCode).end(payload)

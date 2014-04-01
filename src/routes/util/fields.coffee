# Fields.coffee
###
# Responsible for parsing query parameters
###
_und = require('underscore')

DEFAULT_CONFIG =
    sortBy: ''
    fields: ["*"]
    offset: 0
    limit: 1000

# Returns an obj detailing whether controlling how response is formated are disabled or not
exports.parseQuery = (req) ->
    params = req.query

    queryParams        = _und.clone DEFAULT_CONFIG
    queryParams.fields = params.fields.split(",") if params.fields
    queryParams.limit  = parseInt(limit) if params.limit
    queryParams.offset = parseInt(offset) if params.offset

    queryParams

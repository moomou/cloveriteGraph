# Fields.coffee
###
# Responsible for parsing query parameters
###

DEFAULT_CONFIG = {
    fields: ["*"],
    limit: 100,
    offset: 0,
    expand: {},
}

exports.parseQuery = (res) ->
    # Returns an obj detailing whether controlling how response is formated are disabled or not
    {
        fields: [],
        expand: {},
        limit: [],
        offset: [],
    }

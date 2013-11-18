# Remote.coffee
###
# Retrieves data from remote source
###

rest = require('restler')

# Remote web service for reading numeric json data
exports.getJSONData = (remoteAddress, cb) ->
    return cb("N/A") if not remoteAddress

    rest.get(remoteAddress).on 'complete',
        (remoteData, remoteRes) ->
            if not remoteRes?
                cb("")
            else if remoteRes.headers['content-type'].indexOf('application/json') isnt -1
                cb(remoteData)
            else
                cb("N/A")

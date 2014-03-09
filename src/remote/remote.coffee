# Remote.coffee
#
#
# Retrieves data from remote source. To be separated into a separate
# server. Completely standalone.
#

logger  = require '../util/logger'
restler = require 'restler'
cheerio = require 'cheerio'

# Remote web service for reading numeric json data
exports.getJSONData = (remoteAddress, cb) ->
    logger.debug "Remote getJSONData"
    return cb("N/A", null) if not remoteAddress

    restler.get(remoteAddress).on 'complete',
        (remoteData, remoteRes) ->
            if not remoteRes?
                logger.warning "Remote: No data received"
                cb "no data", null
            else if remoteRes.headers['content-type'].indexOf('application/json') isnt -1
                logger.debug "Remote: OK"
                cb null, remoteData
            else
                logger.warning "Remote: Not JSON"
                cb "not json", null

exports.getDOMData = (remoteAddress, selector, cb) ->
    logger.debug "Remote getDOMData"
    return cb("N/A") if not remoteAddress

    restler.get(remoteAddress).on 'complete',
        (remoteData, remoteRes) ->
            if not remoteRes?
                logger.warning "Remote: No data received"
                cb "no data", null
            else
                console.log remoteData
                $ = cheerio.load remoteData
                selected = $(selector)
                value = selected.html() or selected.text() or selected.val()
                cb null, value

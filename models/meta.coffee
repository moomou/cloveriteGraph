#meta.coffee

_und = require 'underscore'

Setup = require './setup'
redis = Setup.db.redis

MetaSchema = {
    "createdAt": -1,    #time created
    "modifiedAt": -1,   #last modified time
}

module.exports = class Meta
    constructor: (@_node) ->

    #calling save on meta data 
    #automatically increases ver and modifiedAt tim
    save: () ->
        @_node.data.modifiedAt = new Date().getTime() / 1000

        if @_node.data.createdAt < 0
            @_node.data.createdAt = new Date().getTime() / 1000

###
Static Method
###
Meta.deserialize = (data) ->

Meta.get = (id, cb) ->
    
Meta.put = (nodeId, reqBody, cb) ->

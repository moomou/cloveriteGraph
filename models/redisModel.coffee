# Base Class for Redis backed model
_und = require 'underscore'
Logger = require 'util'

Setup = require './setup'
Neo = require './neo'
redis = Setup.db.redis

SchemaUtil = require './stdSchema'

module.exports = class RedisModel
    @Name: "dummy"
    @Schema: {}

    _del = (prefix, id, cb) ->
        redis.del "#{prefix}:#{id}", cb
        
    _save = (prefix, id, jsonString, cb) ->
        await
            redis.set "#{prefix}:#{id}", jsonString, defer err, res

        if not err
            cb null, JSON.parse jsonString
        else
            cb err, null

    _load = (prefix, id, cb) ->
        await
            redis.get "#{prefix}:#{id}", defer err, jsonString

        console.log jsonString
        if not err
            cb null, JSON.parse jsonString
        else
            cb err, null

    @create: (data, cb) ->
        uniqueId = (+new Date()).toString(36)
        dataCopy = _und.clone @deserialize data
        dataCopy.id = uniqueId
        jsonString = @getJSONString dataCopy

        _save @getPrefix(), uniqueId, jsonString, cb

    @show = (id, cb) ->
        return cb validationError: "No id provided.", null if not id

        _load @getPrefix(), id, cb

    @update: (id, body, cb) ->
        return cb validationError: "Id in data and url do not match.", null if body.id != id
        dataCopy = _und.clone body

        await @show id, defer err, currentObj

        _und.extend currentObj, @deserialize dataCopy
        _save @getPrefix(), JSON.stringify currentObj, cb

    @delete: (id, cb) ->
        return cb validationError: "No id provided.", null if not id

        _del @getPrefix(), id, cb

    @getJSONString = (data) ->
        dataWithMetaData = @fillMetaData data
        JSON.stringify dataWithMetaData

    @deserialize: (data) ->
        Neo.deserialize @Schema, data

    @fillMetaData: (data) ->
        Neo.fillMetaData data

    @getPrefix: () -> @Name

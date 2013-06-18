_und = require 'underscore'
Setup = require './setup'
db = Setup.db

module.exports = class Neo
    constructor: (@_node) ->

    serialize: () ->
        data = @_node.data
        _und.extend data, id: @_node.id
        return data

    update: (newData) ->
        if newData.version != @_node.data.version
            return false
        _und.extend @_node.data, newData
        return true

    save: (cb) ->
        @_node.save (err) -> cb err

    del: (cb) ->
        @_node.del (err) -> cb err, true

Neo.create = (Class, reqBody, index, cb) ->
    data = Class.deserialize(reqBody)
    node = db.neo.createNode data
    obj = new Class(node)

    node.save (err) ->
        return cb(err, null) if err
        node.index index.INDEX_NAME,
            index.INDEX_KEY,
            index.INDEX_VAL,
            (err) ->
                return cb(err, null) if err
                cb(null, obj)

Neo.get = (Class, id, cb) ->
    db.neo.getNodeById id,
        (err, node) ->
            return cb(err, null) if err
            cb(null, new Class node)

Neo.put = (Class, nodeId, reqBody, cb) ->
    Neo.get Class, nodeId, (err, obj) ->
        return cb(err, null) if err

        valid = obj.update(reqBody)
        if valid
            obj.save (err) ->
                return cb(err, null) if err
                return cb(null, obj)
        cb(err, null)

Neo.query = (Class, query, params, cb) ->
    db.neo.query(
        query,
        params,
        (err, res) ->
            return cb(err, null) if err
            cb(null, res)
    )

Neo.createLink = (srcNode, destNode, linkName, linkData, cb) ->

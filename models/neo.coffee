_und = require 'underscore'
Setup = require './setup'
db = Setup.db

MetaSchema = {
    createdAt: -1,    #time created
    modifiedAt: -1,   #last modified time
    private: false
    version: 0
}

module.exports = class Neo
    constructor: (@_node) ->

    serialize: (cb, extraData) ->
        extraData ?= {}
        data = @_node.data

        _und.extend data, id: @_node.id, extraData

        return cb(data) if cb
        return data

    update: (newData) ->
        if newData.version != @_node.data.version
            return false
        _und.extend @_node.data, newData
        return true

    save: (cb) ->
        @_node.data.modifiedAt = new Date().getTime() / 1000

        if @_node.data.createdAt < 0
            @_node.data.createdAt = new Date().getTime() / 1000

        @_node.data.version += 1
        @_node.save (err) -> cb err

    del: (cb) ->
        @_node.del (err) -> cb err, true

Neo.deserialize = (ClassSchema, data) ->
    _und.defaults data, ClassSchema
    return data

Neo.create = (Class, reqBody, index, cb) ->
    data = Class.deserialize(reqBody)

    _und.extend(data, MetaSchema)

    node = db.neo.createNode data
    
    obj = new Class(node)
    
    await
        obj.save defer(saveErr)

    await
        node.index index.INDEX_NAME,
            index.INDEX_KEY,
            index.INDEX_VAL,
            defer(indexErr)
            
    return cb(saveErr, null) if saveErr
    return cb(indexErr, null) if indexErr
    return cb(null, obj)

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

_und = require 'underscore'
Setup = require './setup'
db = Setup.db

###
#Normal values related to transaction; 
#Permission not implemented here
###
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

Neo.fillIndex = (indexes, data) ->
    result = _und.clone indexes
    _und.map(result,
        (index) ->
            index['INDEX_VALUE'] = data[index['INDEX_KEY']]
    )
    result

Neo.deserialize = (ClassSchema, data) ->
    _und.defaults data, ClassSchema
    return data

Neo.create = (Class, reqBody, indexes, cb) ->
    data = Class.deserialize(reqBody)
    _und.extend(data, MetaSchema)

    node = db.neo.createNode data
    obj = new Class(node)
    await obj.save defer(saveErr)
    return cb(saveErr, null) if saveErr

    await
        for index, i in Neo.fillIndex(indexes, reqBody)
            node.index index.INDEX_NAME,
                index.INDEX_KEY,
                index.INDEX_VALUE,
                defer(err, ind)

    return cb(indexErr, null) if err
    
    console.log "CREATED: " + Class.Name
    return cb(null, obj)

Neo.get = (Class, id, cb) ->
    db.neo.getNodeById id,
        (err, node) ->
            return cb(err, null) if err
            cb(null, new Class node)

Neo.put = (Class, nodeId, reqBody, cb) ->
    Class.get nodeId, (err, obj) ->
        return cb(err, null) if err

        valid = obj.update(reqBody)
        if valid
            obj.save (err) ->
                return cb(err, null) if err
                return cb(null, obj)
        cb(err, null)

Neo.find = (Class, indexName, key, value, cb) ->
    db.neo.getIndexedNode indexName,
        key,
        value,
        (err, node) ->
            return cb(err, null) if err
            return cb(null, new Class node) if node
            return cb(null, null)

Neo.getOrCreate = (Class, reqBody, cb) ->
    if reqBody['id']
        return Class.get reqBody['id'], cb
    
    #No Id provided, search for it
    await
        Neo.find Class,
            Class.INDEX_NAME,
            'name',
            reqBody['name'],
            defer(err, obj)
    if obj
        console.log Class.Name + ": " + reqBody.toString()
        return cb(null, obj) if obj

    #Not found, create
    return Class.create(reqBody, cb)

#Cypher 
Neo.query = (Class, query, params, cb) ->
    db.neo.query query,
        params,
        (err, res) ->
            return cb(err, null) if err
            cb(null, res)

Neo.search = (Class, indexName, query, cb) ->
    db.neo.queryNodeIndex indexName,
        query,
        (err, nodes) ->
            cb err if err
            cb(null, _und.map(nodes, (node)-> new Class node))

Neo.createLink = (srcNode, destNode, linkName, linkData, cb) ->

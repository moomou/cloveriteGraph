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

Neo.MetaSchema = MetaSchema

Neo.fillIndex = (indexes, data) ->
    result = _und.clone indexes
    _und.map(result,
        (index) ->
            index['INDEX_VALUE'] = data[index['INDEX_KEY']]
    )
    return result

Neo.deserialize = (ClassSchema, data) ->
    data = _und.clone data

    validKeys = ['id', 'version', 'private']
    validKeys = _und.union(_und.keys(ClassSchema),
        validKeys)

    _und.defaults data, ClassSchema
    return _und.pick(data, validKeys)

Neo.index = (node, indexes, reqBody, cb = null) ->
    for index, i in Neo.fillIndex(indexes, reqBody)
        console.log index
        node.index index.INDEX_NAME,
            index.INDEX_KEY,
            index.INDEX_VALUE,
            (err, ind) ->
                cb(err, null) if cb and err
                cb(null, ind) if cb

Neo.create = (Class, reqBody, indexes, cb) ->
    #Clean input data
    data = Class.deserialize(reqBody)
    omitKeys = _und.union(['id'], _und.keys(MetaSchema))
    data = _und.omit(data, omitKeys)
    _und.extend(data, MetaSchema)

    console.log data

    node = db.neo.createNode data
    obj = new Class(node)

    await obj.save defer(saveErr)
    return cb(saveErr, null) if saveErr

    Neo.index(node, indexes, reqBody)

    console.log "CREATED: " + Class.Name
    return cb(null, obj)

Neo.getRel = (Class, id, cb) ->
    db.neo.getRelationshipById id,
        (err, rel) ->
            return cb(err, null) if err
            cb(null, new Class rel)

Neo.get = (Class, id, cb) ->
    db.neo.getNodeById id,
        (err, node) ->
            return cb(err, null) if err
            cb(null, new Class node)

Neo.put = (Class, nodeId, reqBody, cb) ->
    data = Class.deserialize(reqBody)

    Class.get nodeId, (err, obj) ->
        return cb(err, null) if err
        valid = obj.update(data)

        if valid
            await obj.save defer(saveErr)

        return cb(saveErr, null) if saveErr
        return cb(null, obj)

Neo.findRel = (Class, indexName, key, value, cb) ->
    db.neo.getIndexedRelationship indexName,
        key,
        value,
        (err, node) ->
            return cb(err, null) if err
            return cb(null, new Class node) if node
            return cb(null, null)

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

#Lucene
Neo.search = (Class, indexName, query, cb) ->
    db.neo.queryNodeIndex indexName,
        query,
        (err, nodes) ->
            cb err if err
            cb(null, _und.map(nodes, (node)-> new Class node))

Neo.createLink = (srcNode, destNode, linkName, linkData, cb) ->


_und   = require 'underscore'

Logger = require '../util/logger'
db     = require('./setup').db

class Neo
    constructor: (@_node) ->

class Node extends Neo
    @Name: "dummyNeo"
    @Schema: {}
    @SkipKeys: []
    @ExtraMeta: {}
    @Indexes: null
    @Class: null

    _ToOmitKeys = () -> _und.clone([
        'id',
        'createdAt',
        'modifiedAt',
        'version',
        'nodeType'
    ])

    ###
    # Normal values related to transaction;
    # Permission not implemented here
    ###
    _MetaSchema = () -> _und.clone
        createdAt: -1,    #time created
        modifiedAt: -1,   #last modified time
        private: false
        version: 0
        nodeType: ''

    _save = (obj, cb) ->
        cb ?= () ->
        obj._node.data.modifiedAt = new Date().getTime() / 1000

        if obj._node.data.createdAt < 0
            obj._node.data.createdAt = new Date().getTime() / 1000

        obj._node.data.version += 1
        obj._node.save (err) -> cb err

    _del = (cb) ->
        cb ?= () ->
        # Remove all rels + node
        delQuery = "START n=node(#{@_node.id}) MATCH n-[r]-() DELETE n, r;"
        Neo.query null, delQuery, {}, cb

    _load = (id, cb) ->
        db.neo.getNodeById id,
            (err, node) ->
                return cb err, null if err
                cb null, node

    _update = (newData, obj) ->
        console.log "Current Data VER: " + obj._node.data.version
        console.log "Input Data VER: " + newData.version

        if newData.version != obj._node.data.version
            return "Version number incorrect"

        # Cannot take a public entity and set it to private
        if not obj._node.data.private and newData.private
            return "Cannot take a public entity and set it to private"

        _und.extend obj._node.data, newData
        false

    # cb should be last!
    @serialize: (cb, extraData) ->
        console.log "Serializing"
        extraData ?= {}
        data = @_node.data

        _und.extend data, id: @_node.id, extraData

        return cb(data) if cb
        return data
    @create = (reqBody, indexes, cb) ->
        # Clean input data
        data = @deserialize(reqBody)
        data = _und.omit data,
            _und.extend _ToOmitKeys(), @SkipKeys

        _und.defaults data,
            _und.extend _MetaSchema(), @ExtraMeta

        node = db.neo.createNode data
        await _save obj, defer(saveErr)
        return cb saveErr, null if saveErr

        console.log "Starting to index"
        obj = new Neo node
        @index obj, obj.serialize()

        console.log "CREATED: " + @Name
        cb(null, obj)

    @show = (Class, id, cb) ->
        db.neo.getNodeById id,
            (err, node) ->
                return cb(err, null) if err
                cb(null, new Class node)

    @update = (Class, nodeId, reqBody, cb) ->
        data = Class.deserialize(reqBody)
        console.log "ID: " + nodeId

        Class.get nodeId, (err, obj) ->
            return cb(dbError: err, null) if err

            err = _update data, obj
            if not err
                console.log "Saving..."
                await _save obj defer saveErr
                @index obj, obj.serialize()
                return cb saveErr, null if saveErr
                return cb null, obj
            else
                console.log "Failed"
                return cb validationError: errMsg, obj

    @fillMetaData = (data) ->
        cData = _und.clone(data)
        _und.extend(cData, MetaSchema)

        cData.createdAt =
            cData.modifiedAt = new Date().getTime() / 1000

        cData.version += 1
        cData

    @fillIndex = (indexes, data) ->
        result = _und.clone indexes

        _und.map(result,
            (index) ->
                index['INDEX_VALUE'] = encodeURIComponent(data[index['INDEX_KEY']].trim())
        )

        _und.filter(result, (index) -> not _und.isUndefined index['INDEX_VALUE'])

    @deserialize = (ClassSchema, data) ->
        data = _und.clone data

        validKeys = ['id', 'version', 'private']
        validKeys = _und.union(_und.keys(ClassSchema), validKeys)

        _und.defaults data, ClassSchema
        cleaned = _und.pick data, validKeys
        cleaned

    @index = (node, indexes, reqBody, cb = null) ->
        console.log "~~~Indexing~~~"
        console.log reqBody

        for index, i in Neo.fillIndex(indexes, reqBody)
            console.log index
            node.index index.INDEX_NAME,
                index.INDEX_KEY,
                index.INDEX_VALUE,
                (err, ind) ->
                    cb(err, null) if cb and err
                    cb(null, ind) if cb

Neo.getRel = (Class, id, cb) ->
    db.neo.getRelationshipById id,
        (err, rel) ->
            return cb(err, null) if err
            cb(null, new Class rel)



Neo.putRel = (Class, relId, reqBody, cb) ->
    data = Class.deserialize(reqBody)

    Class.get relId, (err, obj) ->
        return cb(err, null) if err
        obj._node.data = data
        await obj._node.save(defer(err))

        if not err
            Neo.index(obj._node, Class.Indexes, obj.serialize())
            cb(null, obj)
        else
            console.log "Failed"
            cb(err, obj)

Neo.findRel = (Class, indexName, key, value, cb) ->
    db.neo.getIndexedRelationship indexName,
        key,
        value,
        (err, node) ->
            return cb(err, null) if err
            return cb(null, new Class node) if node
            return cb(null, null)

Neo.find = (Class, indexName, key, value, cb) ->
    Logger.debug("Neo Find Index: " + indexName)
    Logger.debug("Neo Find Key: " + key)
    Logger.debug("Neo Find Key: " + value)

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

    Logger.debug 'Neo Get or Create'
    Logger.debug Class

    # No Id provided, search for it
    await Neo.find Class,
        Class.INDEX_NAME,
        'name',
        reqBody['name'],
        defer(err, obj)

    if obj
        Logger.debug "Neo Find Returned " + Class.Name + ": " + reqBody.toString()
        return cb(null, obj) if obj

    #Not found, create
    return Class.create(reqBody, cb)

### Node Specific ###
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

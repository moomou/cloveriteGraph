# Neo.coffee
#
# The base model that other model derives from.

Logger   = require 'util'
_und     = require 'underscore'

Slug     = require '../util/slug'
RedisKey = require('../config').RedisKey
db       = require('./setup').db

###
# Normal values related to transaction;
# Permission not implemented here
###
MetaSchema =
    createdAt    : -1    # time created
    modifiedAt   : -1    # last modified time
    private      : false # whether the data is protected
    slug         : ''    # human readable unique identifier
    nodeType     : ''    # the type of node
    contributors : ['']  # username who contributed to the entity
    version      : 0

ToOmitKeys = [
    'id'
    'createdAt'
    'modifiedAt'
    'version'
    'nodeType'
    'contributors'
]


# Start of class defn
##

module.exports = class Neo
    constructor: (@_node) ->

    # cb should be last!
    serialize: (cb, extraData) ->
        console.log "Serializing"
        extraData ?= {}
        data = @_node.data

        _und.extend data, id: @_node.id, extraData

        return cb(data) if cb
        return data

    # Returns error message if unsuccessful
    update: (newData) ->
        console.log "Existing VER: #{ @_node.data.version}"
        console.log "Modifying VER: #{newData.version}"

        if newData.version != @_node.data.version
            return "Version number incorrect"

        # Cannot take a public entity and set it to private
        if not @_node.data.private and newData.private
            return "Cannot take a public entity and set it to private"

        # Remove old redis key
        await db.redis.hdel RedisKey.slugToId, @_node.data.slug, defer(err)
        _und.extend @_node.data, newData

        return false

    save: (cb) ->
        cb ?= () ->
        @_node.data.modifiedAt = new Date().getTime() / 1000

        if @_node.data.createdAt < 0
            @_node.data.createdAt = new Date().getTime() / 1000

        @_node.data.version += 1
        @_node.save (err) -> cb err

    del: (cb) ->
        cb ?= () ->
        # Remove all rels + node
        delQuery = "START n=node(#{@_node.id}) MATCH n-[r]-() DELETE n, r;"
        Neo.query null, delQuery, {}, cb

Neo.MetaSchema = MetaSchema


# Data cleaning, augmenting functions.
##

Neo.fillMetaData = (data) ->
    cData = _und.clone(data)
    _und.extend(cData, MetaSchema)

    cData.createdAt =
        cData.modifiedAt = new Date().getTime() / 1000

    cData.version += 1
    cData

Neo.fillIndex = (indexes, data) ->
    result = _und.clone indexes
    data   = _und.clone data

    _und(result).map (index) ->
        index['INDEX_VALUE'] = encodeURIComponent(data[index['INDEX_KEY']].trim())

    _und.filter(result, (index) -> not _und.isUndefined index['INDEX_VALUE'])

Neo.deserialize = (ClassSchema, data) ->
    data = _und.clone data

    validKeys = ['id', 'version', 'private']
    validKeys = _und.union(_und.keys(ClassSchema), validKeys)

    _und.defaults data, ClassSchema
    cleaned = _und.pick data, validKeys
    cleaned

Neo.parseReqBody = (Class, reqBody) ->
    user =  reqBody.user or "anonymous"

    console.log "I LIKE YOU "
    data      = _und.omit data, ToOmitKeys
    data      = Class.deserialize reqBody
    data.slug = Class.getSlugTitle reqBody

    console.log "I LIKE YOU "
    data.contributors ?= []

    if user not in data.contributors
        data.contributors.push user

    console.log data
    console.log "I LIKE YOU "
    data

# Data DB functions.
##

Neo.index = (node, indexes, reqBody, cb = null) ->
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

Neo.create = (Class, reqBody, indexes, cb) ->
    data = Neo.parseReqBody Class, reqBody
    _und.defaults data, MetaSchema

    node = db.neo.createNode data
    obj  = new Class(node)

    await obj.save defer(saveErr)
    return cb(saveErr, null) if saveErr

    console.log "Starting to index"
    Neo.index(node, Class.Indexes, obj.serialize())

    console.log "CREATED: " + Class.Name

    # Update the slug
    await db.redis.hset RedisKey.slugToId, node.data.slug, node.id, defer(err, res)
    return cb(null, obj)

Neo.get = (Class, id, cb) ->
    db.neo.getNodeById id,
        (err, node) ->
            return cb(err, null) if err
            cb(null, new Class node)

Neo.put = (Class, nodeId, reqBody, cb) ->
    console.log reqBody

    data         = Neo.parseReqBody Class, reqBody
    data.version = reqBody.version

    Class.get nodeId, (err, obj) ->
        return cb(dbError: err, null) if err
        errMsg = obj.update(data)

        if not errMsg
            await obj.save defer saveErr

            Neo.index(obj._node, Class.Indexes, obj.serialize())

            if saveErr
                cb(saveErr, null)
            else
                cb(null, obj)
        else
            return cb validationError: errMsg, obj

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


# Relation DB functions
##

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


# Node Specific
Neo.query = (Class, query, params, cb) ->
    db.neo.query query,
        params,
        (err, res) ->
            return cb(err, null) if err
            cb(null, res)

# Lucene
Neo.search = (Class, indexName, query, cb) ->
    db.neo.queryNodeIndex indexName,
        query,
        (err, nodes) ->
            cb err if err
            cb(null, _und.map(nodes, (node)-> new Class node))
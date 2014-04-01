# User.coffee
#
# Defines the field and schema of the user object in neo4j.

_und       = require 'underscore'

redis      = require('./setup').db.redis

Logger     = require '../util/logger'
Neo        = require './neo'
Constants  = require('../config').Constants
SchemaUtil = require './stdSchema'

INDEX_NAME = 'nUser'

Indexes = [
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'accessToken',
        INDEX_VALUE: ''
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'username',
        INDEX_VALUE: ''
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'email',
        INDEX_VALUE: ''
    }
]

UserSchema =
    # Configured Values
    email               : ''
    username            : ''

    # Calculated Values
    emailHash           : ''
    accessToken         : ''
    reputation          : 'Z'
    createdCount        : 0
    modifiedCount       : 0

SchemaValidation =
    email     : SchemaUtil.required('string')
    username  : SchemaUtil.required('string')

ToOmitKeys = ["contributors", "slug"]

# Private constructor
module.exports = class User extends Neo
    constructor: (@_node) ->
        super @_node

    serialize: (cb, extraData) ->
        data = @_node.data
        _und.extend data, id: @_node.id, extraData

        if cb
            cb _und.omit data, ToOmitKeys
        else
            _und.omit data, ToOmitKeys

User.Name       = 'nUser'
User.INDEX_NAME = INDEX_NAME
User.Indexes    = Indexes

#User.getSlugTitle = (data) ->
#    throw "User getSlug Not Implemented"

User.validateSchema = (data) ->
    SchemaUtil.validate SchemaValidation, data

User.deserialize = (data) ->
    cleaned = Neo.deserialize UserSchema, data
    _und.omit cleaned, ToOmitKeys

User.create = (reqBody, cb) ->
    reqBody.private = true
    Neo.create User, reqBody, Indexes, cb

User.get = (id, cb) ->
    digitOnly = /^\d+$/.test id

    if digitOnly
        Neo.get User, id, cb
    else
        Neo.find User, User.INDEX_NAME, 'username', id, cb

User.getOrCreate = (reqBody, cb) ->
    throw "User getOrCreate Not Implemented"

User.put = (nodeId, reqBody, cb) ->
    Neo.put User, nodeId, reqBody, cb

User.find = (key, value, cb) ->
    Neo.find User, User.INDEX_NAME, key, value, cb

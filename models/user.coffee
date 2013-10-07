_und = require 'underscore'
Logger = require 'util'

Neo = require './neo'

Setup = require './setup'
redis = Setup.db.redis

SchemaUtil = require './stdSchema'
Constants = SchemaUtil.Constants

INDEX_NAME = 'nUser'
Indexes = [
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'reputation',
        INDEX_VALUE: ''
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'accessToken',
        INDEX_VALUE: ''
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'lastname',
        INDEX_VALUE: ''
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'firstname',
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

UserSchema = {
    # Configured Values
    email: '',
    username: '',
    firstname: '',
    lastname: '',

    # Calculated Values
    accessToken: ''
    reputation: 'Z',
    createdCount: 0,
    modifiedCount: 0,
}

SchemaValidation = {
    email: SchemaUtil.required('string'),
    username: SchemaUtil.required('string'),
    firstname: SchemaUtil.required('string'),
    lastname: SchemaUtil.required('string'),
}

# Private constructor
module.exports = class User extends Neo
    constructor: (@_node) ->
        super @_node

User.Name = 'nUser'
User.INDEX_NAME = INDEX_NAME
User.Indexes = Indexes

User.validateSchema = (data) ->
    SchemaUtil.validate SchemaValidation, data

User.deserialize = (data) ->
    Neo.deserialize UserSchema, data
 
User.create = (reqBody, cb) ->
    Neo.create User, reqBody, Indexes, cb

User.get = (id, cb) ->
    Neo.get User, id, cb

User.getOrCreate = (reqBody, cb) ->
    throw "Not Implemented"

User.put = (nodeId, reqBody, cb) ->
    Neo.put User, nodeId, reqBody, cb

User.find = (key, value, cb) ->
    Neo.find User, User.INDEX_NAME, key, value, cb

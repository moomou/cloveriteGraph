_und = require 'underscore'
Logger = require('util')

Setup = require './setup'
Neo = require './neo'
redis = Setup.db.redis

INDEX_NAME = 'nUser'
Indexes = [
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'reputation',
        INDEX_VALUE: ''
    }
]


UserSchema = {
    createdCount: 0,
    modifiedCount: 0,
    reputation: 'Z',
}

User.Name = 'nUser'
User.INDEX_NAME = INDEX_NAME
User.Indexes = Indexes

module.exports = class User extends Neo
    constructor: (@_node) ->
        super @_node

User.deserialize = (data) ->
    Neo.deserialize UserSchema, data
 
User.create = (cb) ->
    Neo.create User, UserSchema, Indexes, cb

User.get = (id, cb) ->
    Neo.get User, id, cb

User.getOrCreate = (reqBody, cb) ->
    throw "Not Implemented"

User.put = (nodeId, reqBody, cb) ->
    Neo.put User, nodeId, reqBody, cb

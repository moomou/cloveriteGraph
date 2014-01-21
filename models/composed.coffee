#composed.coffee
_und = require 'underscore'
Logger = require 'util'

Setup = require './setup'
RedisModel = require './redisModel'

SchemaUtil = require './stdSchema'

module.exports = class Composed extends RedisModel
    @Name: "composed"
    @Schema:
        title: ''
        profileIconUrl: ''
        authorName: []
        authorProfileUrl: []
        hashTag: []
        dataChain: []
        entityId: []

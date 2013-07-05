#link.coffee
_und = require 'underscore'

Setup = require './setup'
Neo = require './neo'
redis = Setup.db.redis

StdSchema = require './stdSchema'
Contants = StdSchema.Contants

INDEX_NAME = 'rLink'

Indexes = [
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'name',
        INDEX_VALUE: ''
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'veracity',
        INDEX_VALUE: ''
    }
]

LinkSchema = {
    veracity: 0,      #whehter this link is factual or not
    createdAt: -1,    #time created
    modifiedAt: -1,   #last modified time
    private: false,
    version: 0
}

module.exports = class Link
    constructor: (data) ->
        validKeys = _und.keys(LinkSchema)
        _und.defaults data, LinkSchema

        @name = @normalizeName(data['name'])
        @data = data
    
    normalizeName: (name) ->
        normalized = "_#{name.toUpperCase()}"

###
Static Method
###
Link.Name = 'rLink'
Link.INDEX_NAME = INDEX_NAME

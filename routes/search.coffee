#search.coffee
#Routes to CRUD entities
require('source-map-support').install()

_und = require('underscore')
Neo = require('../models/neo')
Entity = require('../models/entity')
VoteLink = require('../models/votelink')
Attribute = require('../models/attribute')
Tag = require('../models/tag')

StdSchema = require('../models/stdSchema')
Constants = StdSchema.Constants
Response = StdSchema

attrSplit = /\bwith\b/
relSplit = /\bat\b/

# GET /search/:type
exports.searchHandler = (req, res, next) ->
    #assume searching for entity if type not specified
    indexName = req.params.type ? 'entity'

    query = "name:#{req.query['q']}"

    Neo.search Entity, indexName, query, (err, objs) ->
        res.json(_und.map(objs, (obj) -> obj.serialize()))

queryAnalyzer = (query) ->
    #Splits the query into relationship cypher queries
    [entityQuery, remainder] = query.split(attrSplit)
    [attrQuery, remainder] = remainder.split(relSplit)
    ###
    query = [
        'START user=node({userId})',
        'MATCH (user)<-[:REL_ATTRIBUTE]-(attributes)',
        'RETURN attributes, count(attributes)'
    ].join('\n').replace('REL_ATTRIBUTE', REL_ATTRIBUTE)
    ###
    
searchBasic = (Class, indexName, query, cb) ->
    Neo.search Class, indexName, query, cb


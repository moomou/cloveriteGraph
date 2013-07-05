#search.coffee
#Routes to CRUD entities
require('source-map-support').install()

_und = require('underscore')
Neo = require('../models/neo')
Entity = require('../models/entity')
Vote = require('../models/vote')
Attribute = require('../models/attribute')
Tag = require('../models/tag')

StdSchema = require('../models/stdSchema')
Constants = StdSchema.Constants
Response = StdSchema

attrSplit = /\bwith\b/
relSplit = /\bat\b/

searchableClass = {
    entity: Entity,
    attribute: Attribute,
    tag: Tag
}

searchFunc = {
    cypher: Neo.query,
    lucene: Neo.search
}

queryAnalyzer = (searchClass, query) ->
    #Splits the query into relationship cypher queries
    mainQuery = attrQuery = relQuery = ''

    console.log "query: #{query}"
    [mainQuery, remainder] = query.split(attrSplit)

    console.log "mQuery: #{mainQuery}"
    [attrQuery, remainder] = remainder.split(relSplit) if remainder

    console.log "attrQuery: #{attrQuery}"
    console.log "relQuery: #{remainder}"

    mainQuery = mainQuery.trim() unless not mainQuery

    attrQuery = attrQuery.split(' ')
        .map((item) -> item.trim())
        .filter((item) -> item unless not item) unless not attrQuery
    relQuery = remainder.split(' ')
        .map((item) -> item.trim())
        .filter((item) -> item unless not item) unless not remainder
    
    return cypherQueryConstructor(searchClass, mainQuery, attrQuery, relQuery)

cypherQueryConstructor = (searchClass, name = '', attrMatches = [], relMatches = []) ->
    console.log "name: #{name}"
    console.log "attrMatches: #{attrMatches}"
    console.log "relMatches: #{relMatches}"

    #potential injection attack
    startNodeQ = "START n=node:__indexName__('name:#{name}~0.65')"
    endQ = 'RETURN DISTINCT n AS result;'
    
    attrMatchQ = []
    relMatchQ = []

    for attrName, ind in attrMatches
        attrMatchQ.push("MATCH (n)<-[:_ATTRIBUTE]-(attribute) WHERE attribute.name=~'(?i)#{attrName}'")
    attrMatchQ = attrMatchQ.join(' WITH n as n ')

    for relName, ind in relMatches
        relMatchQ.push("MATCH (n)-[r]->(related) WHERE related.name=~'(?i)#{relName}'")
    relMatchQ = relMatchQ.join(' WITH n as n ')

    switch searchClass
        when Tag
            return [startNodeQ, "MATCH (n)-[:_TAG]->(entity) WITH entity as n", attrMatchQ,"WITH n as n", relMatchQ,endQ].join('\n')
        when Attribute
            return [startNodeQ, "MATCH (n)-[:_ATTRIBUTE]->(entity) WITH entity as n", attrMatchQ,"WITH n as n", relMatchQ,endQ].join('\n')
        else [startNodeQ,attrMatchQ,"WITH n as n", relMatchQ, endQ].join('\n')

luceneQueryContructor = (query) ->
    queryString = []

    for key, val in query
        queryString.push("#{key}:#{val}")

    return queryString.join("AND")

# GET /search/:type
exports.searchHandler = (req, res, next) ->
    #generic searching if no type specified
    return res.json {} unless req.query['q'] 

    if req.params.type
        searchClasses = [searchableClass[req.params.type]]
    else
        searchClasses = _und.values searchableClass

    results = []

    #serial searches, continue only if no result
    await
        for searchClass, ind in searchClasses
            query = queryAnalyzer(searchClass, req.query['q'])

            Neo.query searchClass,
                query.replace('__indexName__', searchClass.INDEX_NAME),
                {},
                defer(err, results[ind])

    blobResults = []
    identified = {}

    for result, indX in results
        for obj, indY in result #always return entity results
            entitySerialized = (new Entity obj.result).serialize()

            if not identified[entitySerialized.id] #do not duplicate result
                blobResults.push(entitySerialized)
                identified[entitySerialized.id] = true

    #cache results?
     
    res.json(blobResults)

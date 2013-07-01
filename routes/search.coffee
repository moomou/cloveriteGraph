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

queryAnalyzer = (query) ->
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
    
    return cypherQueryConstructor(mainQuery, attrQuery, relQuery)

cypherQueryConstructor = (name = '', attrMatches = [], relMatches = []) ->
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

    return ['cypher', [startNodeQ,attrMatchQ,"WITH n as n", relMatchQ,endQ].join('\n')]

luceneQueryContructor = (query) ->
    queryString = []

    for key, val in query
        queryString.push("#{key}:#{val}")

    return queryString.join("AND")

# GET /search/:type
exports.searchHandler = (req, res, next) ->
    #generic searching if no type specified

    if req.params.type
        searchClasses = [searchableClass[req.params.type]]
    else
        searchClasses = searchableClass

    [queryType, query] = queryAnalyzer(req.query['q'])
    search = searchFunc[queryType]

    console.log "CYPHER_QUERY: #{query}"
    results = []
    await
        for searchClass, ind in searchClasses
            search searchClass,
                query.replace('__indexName__', searchClass.INDEX_NAME),
                {},
                defer(err, results[ind])

    blobResults = {}
    for result, indX in results
        searchClassBlob = []
        for obj, indY in result
            searchClassBlob.push((new searchClasses[indX] obj.result).serialize())
        blobResults[searchClasses[indX].Name] = searchClassBlob

    res.json(blobResults)

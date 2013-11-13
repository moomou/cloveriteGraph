#search.coffee
#Routes to CRUD entities
require('source-map-support').install()

_und = require('underscore')
trim = require('../misc/stringUtil').trim

Neo = require('../models/neo')
Entity = require('../models/entity')
Ranking = require('../models/ranking')
Vote = require('../models/vote')
Attribute = require('../models/attribute')
Tag = require('../models/tag')

SchemaUtil = require('../models/stdSchema')
Constants = SchemaUtil.Constants

Utility = require('./utility')

OTHER_SPLIT_REGEX = /\bwith\b/
REL_SPLIT_REGEX = /\bvia\b/

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
    mainQuery = otherQuery = relQuery = ''

    console.log "query: #{query}"
    [mainQuery, remainder] = query.split(OTHER_SPLIT_REGEX)

    console.log "mainQuery: #{mainQuery}"
    [otherQuery, remainder] = remainder.split(REL_SPLIT_REGEX) if remainder

    console.log "otherQuery: #{otherQuery}"
    console.log "relQuery: #{remainder}"

    mainQuery = encodeURIComponent _und.escape mainQuery.trim() unless not mainQuery

    otherQuery = otherQuery.split(',')
        .map((item) -> encodeURIComponent _und.escape item.trim())
        .filter((item) -> item unless not item) unless not otherQuery

    relQuery = remainder.split(',')
        .map((item) -> encodeURIComponent _und.escape item.trim())
        .filter((item) -> item unless not item) unless not remainder

    return cypherQueryConstructor(searchClass, mainQuery, otherQuery, relQuery)

cypherQueryConstructor = (searchClass, name = '', otherMatches = [], relMatches = []) ->
    console.log "name: #{name}"
    console.log "otherMatches: #{otherMatches}"
    console.log "relationMatches: #{relMatches}"

    #potential injection attack
    startNodeQ = "START n=node:__indexName__('name:#{name}~0.65')"
    endQ = 'RETURN DISTINCT n AS result;'

    otherMatchQ = []

    for otherName, ind in otherMatches
        if ind < relMatches.length
            relationship = relMatches[ind]
        else
            relationship = Constants.REL_ATTRIBUTE
        otherMatchQ.push("MATCH (n)<-[:#{relationship}]-(other) WHERE other.name=~'(?i)#{decodeURIComponent otherName}'")

    otherMatchQ = otherMatchQ.join(' WITH n as n ')

    switch searchClass
        when Tag
            return [startNodeQ, "MATCH (n)-[:_TAG]->(entity) WITH entity as n", otherMatchQ, "WITH n as n", endQ].join('\n')
        when Attribute
            return [startNodeQ, "MATCH (n)-[:_ATTRIBUTE]->(entity) WITH entity as n", otherMatchQ, "WITH n as n", endQ].join('\n')
        else [startNodeQ, otherMatchQ, "WITH n as n", endQ].join('\n')

luceneQueryContructor = (query) ->
    queryString = []

    for key, val in query
        queryString.push("#{key}:#{val}")

    return queryString.join("AND")

# GET /search/:type
exports.searchHandler = (req, res, next) ->
    #generic searching if no type specified
    return res.json {} unless req.query['q']

    cleanedQuery = trim req.query.q

    if req.params.type
        searchClasses = [searchableClass[req.params.type]]
    else
        searchClasses = _und.values searchableClass

    results = []
    errs = []

    rankingQuery = cleanedQuery.indexOf("ranking:") >= 0

    #serial searches, continue only if no result
    await
        Utility.getUser req, defer(errU, user)

        if rankingQuery
            rankingName = encodeURIComponent _und.escape cleanedQuery.substr(8).trim()
            cQuery = "START n=node:nRanking('name:#{rankingName}~0.25') MATCH (n)-[r:_RANK]->(x)
                RETURN DISTINCT n.name AS rankingName, r.rank AS rank, x AS entity ORDER BY n.name, r.rank;"

            Neo.query Ranking,
                cQuery,
                {},
                defer(errs[ind], rankingResult)

        # TODO Don't want if else, should be functional;
        else
            for searchClass, ind in searchClasses
                query = queryAnalyzer(searchClass, cleanedQuery)
                console.log query
                Neo.query searchClass,
                    query.replace('__indexName__', searchClass.INDEX_NAME),
                    {},
                    defer(errs[ind], results[ind])

    err = _und.find errs, (err) -> err
    return res.status(500).json(
        error: "Unable to execute query. Please try again later") if err or errU

    blobResults = []
    identified = {}

    if rankingQuery
        for item, ind in rankingResult
            if not identified[item.rankingName]
                identified[item.rankingName] = []

            entity = (new Entity item.entity)

            await
                Utility.hasPermission user, entity, defer(err, authorized)

            continue if not authorized

            await
                Utility.getEntityAttributes(entity, defer(attrBlobs))

            entitySerialized = entity.serialize(null, attributes: attrBlobs)
            identified[item.rankingName].push(entitySerialized)

        return res.json identified

    for result, indX in results
        for obj, indY in result #always return entity results
            entity = (new Entity obj.result)

            await Utility.hasPermission user, entity, defer(err, authorized)
            continue if not authorized

            await Utility.getEntityAttributes(entity, defer(attrBlobs))
            entitySerialized = entity.serialize(null, attributes: attrBlobs)

            if not identified[entitySerialized.id] #do not duplicate result
                blobResults.push(entitySerialized)
                identified[entitySerialized.id] = true

    #cache results?
    res.json(blobResults)

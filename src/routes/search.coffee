# search.coffee
#
# Routes to CRUD entities

require('source-map-support').install()

_und            = require('underscore')

Neo             = require('../models/neo')
Entity          = require('../models/entity')
Ranking         = require('../models/ranking')
Vote            = require('../models/vote')
Attribute       = require('../models/attribute')
Tag             = require('../models/tag')

Constants       = require('../config').Constants

Fields          = require('./util/fields')
Response        = require('./util/response')
ErrorDevMessage = Response.ErrorDevMessage

EntityUtil      = require('./entity/util')
Permission      = require('./permission')

OTHER_SPLIT_REGEX = /\bwith\b/
REL_SPLIT_REGEX   = /\bvia\b/

searchableClass =
    entity    : Entity
    attribute : Attribute
    tag       : Tag

searchFunc =
    cypher : Neo.query
    lucene : Neo.search

# Splits the query into relationship cypher queries
queryAnalyzer = (searchClass, query) ->
    query     = decodeURI query
    mainQuery = relQuery = contributorQuery = ''

    console.log "query: #{query}"

    [query, contributorQuery] = query.split '@'
    console.log "Searching Contributor #{contributorQuery}"

    [mainQuery, remainder]    = query.split ' '
    console.log "mainQuery: #{mainQuery}"

    relQuery = remainder.split '#' if remainder
    console.log "relQuery: #{relQuery}"

    mainQuery = _und(mainQuery.split '#').map((part) ->
        encodeURIComponent _und.escape part.trim()) if mainQuery

    relQuery = _und(relQuery)
        .map((item) -> encodeURIComponent _und.escape item.trim())
        .filter((item) -> item) if relQuery

    return cypherQueryConstructor(searchClass, mainQuery, relQuery)

cypherQueryConstructor = (searchClass, mainMatches = [], relMatches = [], skip = 0, limit = 1000) ->
    console.log "mainMatches: #{mainMatches}"
    console.log "relationMatches: #{relMatches}"

    # potential injection attack
    startNodeQ = do () ->
        startingNodes = _und(mainMatches).reduce((start, name) ->
            start + "\"#{name}\"~0.65,"
        , "")
        "START n=node:__indexName__('name:(#{startingNodes})')"

    console.log "TESTING: #{skip}"

    endQ      = "RETURN DISTINCT n AS result SKIP #{skip} LIMIT #{limit};"
    relMatchQ = []

    for relName, ind in relMatches
        relationship = Constants.REL_ATTRIBUTE
        relMatchQ.push "MATCH (n)<-[:#{relationship}]-(other) WHERE other.name=~'(?i)#{decodeURIComponent relName}'"
    relMatchQ = if relMatchQ then relMatchQ.join(' WITH n as n ') else ""

    switch searchClass
        when Tag
            return [startNodeQ, "MATCH (n)-[:_TAG]->(entity) WITH entity as n", relMatchQ, "WITH n as n", endQ].join('\n')
        when Attribute
            return [startNodeQ, "MATCH (n)-[:_ATTRIBUTE]->(entity) WITH entity as n", relMatchQ, "WITH n as n", endQ].join('\n')
        else
            [startNodeQ, relMatchQ, "WITH n as n", endQ].join('\n')

luceneQueryContructor = (query) ->
    queryString = []

    for key, val in query
        queryString.push("#{key}:#{val}")

    return queryString.join("AND")

serializeEntity = (entity, cb) ->
    await
        EntityUtil.getEntityAttributes entity, defer attrBlobs
        EntityUtil.getEntityData entity, defer dataBlobs

    cb entity.serialize null,
        attributes : attrBlobs
        data       : dataBlobs

serializeSearchResult = (user, searchResult, identified, cb) ->
    identified  ?= []
    blobResults  = []

    for obj, ind in searchResult
        entity = new Entity obj.result

        await Permission.hasPermission user, entity, defer err, authorized
        continue if not authorized
        await serializeEntity entity, defer entitySerialized

        # do not duplicate result
        if not identified[entitySerialized.id]
            blobResults.push entitySerialized
            identified[entitySerialized.id] = true

    console.log "ME OK?"
    cb([blobResults, identified])

# GET /search/:type
exports.searchHandler = (req, res, next) ->
    Response.OKResponse(res)(200, {}) unless req.query.q

    queryParams  = Fields.parseQuery req
    cleanedQuery = req.query.q.trim()

    if req.params.type
        searchClasses = [searchableClass[req.params.type]]
    else
        searchClasses = _und.values searchableClass

    results = []
    errs    = []

    rankingQuery = cleanedQuery.indexOf("ranking:") >= 0

    # Serial searches, continue only if no result
    await
        Permission.getUser req, defer(errU, user)

        # TODO Don't want if else, should be functional;
        if rankingQuery
            rankingName = encodeURIComponent _und.escape cleanedQuery.substr(8).trim()
            cQuery =
                "START n=node:nRanking('name:#{rankingName}~0.25') MATCH (n)-[r:_RANK]->(x)
                RETURN DISTINCT n AS ranking, r.rank AS rank, x AS entity ORDER BY ID(n), r.rank;"

            Neo.query Ranking,
                cQuery,
                {},
                defer errs, result
        else
            for searchClass, ind in searchClasses
                query = queryAnalyzer searchClass, cleanedQuery
                console.log "Query: \n #{query.replace('__indexName__', searchClass.INDEX_NAME)}"
                console.log "=================="

                Neo.query searchClass,
                    query.replace('__indexName__', searchClass.INDEX_NAME),
                    {},
                    defer(errs[ind], results[ind])

    err = _und.find errs, (err) -> err
    return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue()) if err

    blobResults = []
    identified  = []

    # TODO Add next, & prev
    if rankingQuery
        entities = _und(results).map (result) -> result.entity
        await serializeSearchResult user, entities, identified, defer serialized
        [blobResults, identified] = serialized
    else
        for result, ind in results
            await serializeSearchResult user, result, identified, defer serialized
            [blobResults[ind], identified] = serialized if serialized.length == 2

        # flatten results
        blobResults = _und(blobResults).flatten()

    Response.OKResponse(res)(200, blobResults)

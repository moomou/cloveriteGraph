#Construction Cypher Queries and
_und   = require('underscore')
Logger = require '../../util/logger'

class CypherQueryBuilder
    instance = null
    class _CypherQueryBuilder
        constructor: ->
        getOutgoingRelsCypherQuery: (startId, relType) ->
            cypher = "START n=node(#{startId}) MATCH n-[r]->other "

            if relType == "relation"
                cypher += "WHERE type(r) <> #{Constants.REL_VOTED} "
            else
                cypher += "WHERE type(r) = '#{Link.normalizeName relType}'"

            cypher += " RETURN r;"

    @get: -> instance ?= new _CypherQueryBuilder()

class CypherLinkUtil
    @getRelationId: (path) ->
        splits = path.relationships[0]._data.self.split('/')
        splits[splits.length - 1]

    @hasLink: (startNode, otherNode, linkType, dir, cb) ->
        dir ?= "all"

        startNode.path otherNode,
            linkType,
            dir,
            1,              # depth
            'shortestPath', #algo - cannot change?
            (err, path) ->
                Logger.debugging "Cypher hasLink finished"
                return cb(err, null) if err
                if path then cb(null, path) else cb(null, false)

    @createLink: (startNode, otherNode, linkType, linkData, cb) ->
        Logger.debug "Creating linkType: #{linkType}"
        Logger.debug "StartingNode: #{startNode.id}"
        Logger.debug "OtherNode: #{otherNode.id}"
        Logger.debug "LinkType: #{linkType}"

        startNode.createRelationshipTo otherNode,
            linkType,
            linkData,
            (err, link) ->
                Logger.debug "Finished with err: #{err}"
                return cb(new Error("Unable to create link"), null) if err
                return cb(null, link)

    @getOrCreateLink: (Class, startNode, otherNode, linkType, linkData, cb) ->
        await
            @hasLink startNode,
                otherNode,
                linkType,
                "out",
                defer(err, path)

        if not path
            @createLink startNode,
                otherNode
                linkType,
                linkData,
                cb
        else
            relId = @getRelationId path
            Class.get relId, cb

    @updateLink: (Class, startNode, otherNode, linkType, linkData, cb) ->
        await
            @hasLink startNode,
                otherNode,
                linkType,
                "all",
                defer(err, path)
        if err
            Logger.error "UpdateLink ERR #{err}"
            return cb("Unable to retrieve link", null)
        else if not path
            Logger.debug "UpdateLink Didn't find path"
            return cb "Link does not exist", null

        relId = @getRelationId path
        Class.put relId, linkData, cb

    @deleteLink = (Class, startNode, otherNode, linkType, cb) ->
        await
            @hasLink startNode,
                otherNode,
                linkType,
                "out",
                defer(err, path)

        if not path
            return cb(null, null)
        else if err
            return cb("Unable to retrieve link", null)

        relId = @getRelationId path

        await
            Class.get relId, defer(err, link)

        #link._node.del()
        link.del()

    @createMultipleLinks = (startNode, otherNode, links, linkData, cb) ->
        errs = []
        rels = []
        await
            for link, ind in links
                @createLink startNode,
                    otherNode,
                    link,
                    linkData,
                    defer(errs[ind], rels[ind])

        err = _und.find(errs, (err) -> err)
        cb(err, rels)

exports.CypherQueryBuilder = CypherQueryBuilder.get()
exports.CypherLinkUtil = CypherLinkUtil

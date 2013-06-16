_und = require 'underscore'
neo4j = require 'neo4j'
db = neo: new neo4j.GraphDatabase(process.env.NEO4J_URL || 'http://localhost:7474')

#Constants
REL_META = "_meta"

MetaSchema = {
    "createdAt": -1,    #time created
    "modifiedAt": -1,   #last modified time
}

module.exports = class MetaNode
    constructor: (@_node) ->

    serialize: () ->
        data = @_node.data
        _und.extend data, id: @_node.id
        return data

    #calling save on meta data 
    #automatically increases ver and modifiedAt tim
    save: () ->
        @_node.data.modifiedAt = new Date().getTime() / 1000

        if @_node.data.createdAt < 0
            @_node.data.createdAt = new Date().getTime() / 1000

        @_node.save (err) -> cb(err)
            
###
Static Method
###
MetaSchema.updateMeta = (nodeId, cb) ->
    query = [
        'START node=node({nodeId})',
        'MATCH (node)<-[:REL_META]-(meta)',
        'RETURN meta'
    ].join('\n').replace('REL_META', REL_META)

    params = {
        nodeId: nodeId
    }

    db.neo.query(
        query,
        params,
        (err, res) ->
            return cb(err, null) if err
            cb(null, new MetaSchema res[0])
    )

#entity.coffee
#entity model logic.

neo4j = require 'neo4j'
db = new neo4j.GraphDatabase(process.env.NEO4J_URL || 'http://localhost:7474')

#contants

INDEX_NAME = 'node'
INDEX_KEY = 'type'
INDEX_VAL = 'attribute'

REL_RESOURCE = '_resource'

#Private constructor
class Attribute
    constructor: (@_node) ->
    
#Public
#Instance Method
Attribute::save = (callback) ->
    @_node.save (err) -> callback err

Attribute::del = (callback) ->
    @_node.del (err) -> callback err, true

#Static Method
Attribute.create = (data, callback) ->
    node = db.createNode data
    entity = new Attribute(node)
    node.save (err) ->
        return callback(err) if err
        node.index INDEX_NAME,
            INDEX_KEY,
            INDEX_VAL,
            (err) ->
                return callback(err) if err
                callback(null, entity)

Attribute.get = (id, callback) ->
    db.getNodeById id,
        (err, node) ->
            return callback(err) if error
            callback(null, entity)

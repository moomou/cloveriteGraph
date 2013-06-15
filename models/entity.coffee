#entity.coffee
#db = require './setup'
neo4j = require 'neo4j'
db = neo: new neo4j.GraphDatabase(process.env.NEO4J_URL || 'http://localhost:7474')

#contants
INDEX_NAME = 'node'
INDEX_KEY = 'type'
INDEX_VAL = 'entity'

REL_LOCATION = '_location'
REL_AWARD = '_award'
REL_ATTRIBUTE = '_attribute'
REL_PARENT = '_parent'
REL_CHILD = '_child'
REL_CONTAINER = '_container'
REL_RESOURCE = '_resource'

#Private constructor
module.exports = class Entity
    constructor: (@_node) ->

Entity::_getAttribute = (callback) ->
    query = [
        'START user=node({userId})',
        'MATCH (user)<-[:REL_ATTRIBUTE]-(attributes)',
        'RETURN attributes, count(attributes)'
    ].join('\n').replace('REL_ATTRIBUTE', REL_ATTRIBUTE)

    params = {
        userId: @id
    }

    db.neo.query(
        query,
        params,
        (err, res) ->
            return callback(err) if err
            callback(null, res[0])
    )

#Public
#Instance Method
Entity::save = (callback) ->
    @_node.save (err) -> callback err

Entity::del = (callback) ->
    @_node.del (err) -> callback err, true

Entity::vote = (attrId, vote, callback) ->
    
Entity::linkEntity = (other, relation, callback) ->
    @__node.createRelationshipTo other, relation.name, relation.data, (err, res) ->
            return callback err if err
            res.save (err) ->
                return callback err if err
 
Entity::unlinkEntity = (other, relation, callback) ->
    @_node.getRelationships relation, (err, rels) ->
        return callback err if err
        reToOther = []
        reToOther.push rel for rel, i in rels when rel.end is other

        for rel in reToOther
            do (rel) ->
                rel.del (err) -> callback err if err
    
#Static Method
Entity.create = (data, callback) ->
    console.log(db)
    node = db.neo.createNode data
    entity = new Entity(node)
    node.save (err) ->
        callback(err) if err
        node.index INDEX_NAME,
            INDEX_KEY,
            INDEX_VAL,
            (err) ->
                return callback(err) if err
                callback(null, entity)

Entity.get = (id, callback) ->
    db.neo.getNodeById id,
        (err, node) ->
            return callback(err) if err
            callback(null, node)

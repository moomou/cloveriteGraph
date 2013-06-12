#entity.coffee
#entity model logic.

neo4j = require 'neo4j'
db = new neo4j.GraphDatabase(process.env.NEO4J_URL || 'http://localhost:7474')

#contants

INDEX_NAME = 'nodes'
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
class Entity
    constructor: (@_node) ->

Object.defineProperty(
    Entity.prototype,
    'id',
    {
        get: () -> this._node.id
    },
)

Object.defineProperty(
    Entity.prototype,
    'exists',
    {
        get: () -> this._node.exists
    },
)

Object.defineProperty(
    Entity.prototype,
    'name',
    {
        get: () -> this._node.id
    },
)

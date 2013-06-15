neo4j = require 'neo4j'
exports.neo = new neo4j.GraphDatabase(process.env.NEO4J_URL || 'http://localhost:7474')

redis = require 'redis'
exports.rClient = redis.createClient

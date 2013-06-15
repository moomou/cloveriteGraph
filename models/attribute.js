// Generated by IcedCoffeeScript 1.6.2d
(function() {
  var Attribute, INDEX_KEY, INDEX_NAME, INDEX_VAL, REL_RESOURCE, db, neo4j;



  neo4j = require('neo4j');

  db = new neo4j.GraphDatabase(process.env.NEO4J_URL || 'http://localhost:7474');

  INDEX_NAME = 'node';

  INDEX_KEY = 'type';

  INDEX_VAL = 'attribute';

  REL_RESOURCE = '_resource';

  Attribute = (function() {
    function Attribute(_node) {
      this._node = _node;
    }

    return Attribute;

  })();

  Attribute.prototype.save = function(callback) {
    return this._node.save(function(err) {
      return callback(err);
    });
  };

  Attribute.prototype.del = function(callback) {
    return this._node.del(function(err) {
      return callback(err, true);
    });
  };

  Attribute.create = function(data, callback) {
    var entity, node;
    node = db.createNode(data);
    entity = new Attribute(node);
    return node.save(function(err) {
      if (err) {
        return callback(err);
      }
      return node.index(INDEX_NAME, INDEX_KEY, INDEX_VAL, function(err) {
        if (err) {
          return callback(err);
        }
        return callback(null, entity);
      });
    });
  };

  Attribute.get = function(id, callback) {
    return db.getNodeById(id, function(err, node) {
      if (error) {
        return callback(err);
      }
      return callback(null, entity);
    });
  };

}).call(this);

// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Constants, Entity, EntitySchema, INDEX_NAME, Indexes, Logger, Neo, SchemaUtil, SchemaValidation, Slug, entityAttrNegVoteRedisKey, entityAttrPosVoteRedisKey, iced, redis, __iced_k, __iced_k_noop, _und,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  redis = require('./setup').db.redis;

  Logger = require('../util/logger');

  Slug = require('../util/slug');

  SchemaUtil = require('./stdSchema');

  Neo = require('./neo');

  Constants = require('../config').Constants;

  INDEX_NAME = 'nEntity';

  Indexes = [
    {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'name',
      INDEX_VALUE: ''
    }, {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'description',
      INDEX_VALUE: ''
    }
  ];

  EntitySchema = {
    name: 'Name of entity',
    description: '',
    type: '',
    tags: [''],
    imgURL: ''
  };

  SchemaValidation = {
    name: SchemaUtil.required('string'),
    description: SchemaUtil.optional('string'),
    type: SchemaUtil.optional('string'),
    tags: SchemaUtil.optional('array')
  };

  entityAttrPosVoteRedisKey = function(id, aId) {
    return "entity:" + id + "::attr:" + aId + "::positive";
  };

  entityAttrNegVoteRedisKey = function(id, aId) {
    return "entity:" + id + "::attr:" + aId + "::negative";
  };

  module.exports = Entity = (function(_super) {
    __extends(Entity, _super);

    function Entity(_node) {
      this._node = _node;
      Entity.__super__.constructor.call(this, this._node);
    }

    Entity.prototype.getVoteByUser = function(user, cb) {
      var cypher, err, results, userId, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      if (user == null) {
        user = null;
      }
      if (!user) {
        return cb(null, null);
      }
      userId = user._node.id;
      cypher = ["START s=node({entityId}), e=node({userId})", "MATCH (s)-[r:" + Constants.REL_VOTED + "]-(e)", "RETURN r.attrId AS id, r.attrName AS name, r.tone AS vote ORDER BY r.attrId;"];
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "entity.coffee",
          funcname: "Entity.getVoteByUser"
        });
        Neo.query(null, cypher.join("\n"), {
          entityId: _this._node.id,
          userId: userId
        }, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return results = arguments[1];
            };
          })(),
          lineno: 61
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          return cb(err, null);
        }
        return cb(null, results);
      });
    };

    Entity.prototype.getVoteTally = function(attr, cb) {
      var downVote, errN, errP, upVote, voteTally, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      if (attr == null) {
        attr = null;
      }
      if (!attr) {
        return cb(null, null);
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "entity.coffee",
          funcname: "Entity.getVoteTally"
        });
        redis.get(entityAttrPosVoteRedisKey(_this._node.id, attr._node.id), __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              errP = arguments[0];
              return upVote = arguments[1];
            };
          })(),
          lineno: 71
        }));
        redis.get(entityAttrNegVoteRedisKey(_this._node.id, attr._node.id), __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              errN = arguments[0];
              return downVote = arguments[1];
            };
          })(),
          lineno: 73
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (errP || errN) {
          return cb(errP || errN, null);
        }
        voteTally = {
          upVote: parseInt(upVote) || 0,
          downVote: parseInt(downVote) || 0
        };
        return cb(null, voteTally);
      });
    };

    Entity.prototype.vote = function(user, attr, voteLink, cb) {
      var downVote, err, errN, errP, rel, upVote, voteTally, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "entity.coffee",
          funcname: "Entity.vote"
        });
        _this._node.createRelationshipTo(attr._node, Constants.REL_VOTED, voteLink.data, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return rel = arguments[1];
            };
          })(),
          lineno: 90
        }));
        if (user) {
          voteLink.data.attribute = attr.serialize().name;
          user._node.createRelationshipTo(_this._node, Constants.REL_VOTED, voteLink.data, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                err = arguments[0];
                return rel = arguments[1];
              };
            })(),
            lineno: 97
          }));
        }
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          return cb(err);
        }
        redis.incr("entity:" + _this._node.id + "::attr:" + attr._node.id + "::" + voteLink.data.tone);
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "entity.coffee",
            funcname: "Entity.vote"
          });
          redis.get(entityAttrPosVoteRedisKey(_this._node.id, attr._node.id), __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                errP = arguments[0];
                return upVote = arguments[1];
              };
            })(),
            lineno: 105
          }));
          redis.get(entityAttrNegVoteRedisKey(_this._node.id, attr._node.id), __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                errN = arguments[0];
                return downVote = arguments[1];
              };
            })(),
            lineno: 107
          }));
          __iced_deferrals._fulfill();
        })(function() {
          if (errP || errN) {
            return cb(errP || errN, null);
          }
          voteTally = {
            upVote: parseInt(upVote) || 0,
            downVote: parseInt(downVote) || 0
          };
          return cb(null, voteTally);
        });
      });
    };

    Entity.prototype.unlinkEntity = function(other, relation, cb) {
      return this._node.getRelationships(relation, function(err, rels) {
        var i, reToOther, rel, _i, _j, _len, _len1, _results;
        if (err) {
          return cb(err);
        }
        reToOther = [];
        for (i = _i = 0, _len = rels.length; _i < _len; i = ++_i) {
          rel = rels[i];
          if (rel.end === other) {
            reToOther.push(rel);
          }
        }
        _results = [];
        for (_j = 0, _len1 = reToOther.length; _j < _len1; _j++) {
          rel = reToOther[_j];
          _results.push((function(rel) {
            return rel.del(function(err) {
              if (err) {
                return cb(err);
              }
            });
          })(rel));
        }
        return _results;
      });
    };

    return Entity;

  })(Neo);


  /*
  Static Method
  */

  Entity.NodeType = 'nEntity';

  Entity.Name = 'nEntity';

  Entity.Indexes = Indexes;

  Entity.INDEX_NAME = INDEX_NAME;

  Entity.validateSchema = function(data) {
    return SchemaUtil.validate(SchemaValidation, data);
  };

  Entity.getSlugTitle = function(data) {
    return Slug.slugify(data.name);
  };

  Entity.deserialize = function(data) {
    return Neo.deserialize(EntitySchema, data);
  };

  Entity.create = function(reqBody, cb) {
    return Neo.create(Entity, reqBody, Indexes, cb);
  };

  Entity.get = function(id, cb) {
    return Neo.get(Entity, id, cb);
  };

  Entity.getOrCreate = function(reqBody, cb) {
    Logger.debug("Entity getOrCreate");
    return Neo.getOrCreate(Entity, reqBody, cb);
  };

  Entity.put = function(nodeId, reqBody, cb) {
    var tags;
    tags = reqBody.tags || [];
    reqBody.tags = _und.filter(tags, function(tag) {
      return tag && _und.isString(tag);
    });
    return Neo.put(Entity, nodeId, reqBody, cb);
  };

}).call(this);

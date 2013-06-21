// Generated by IcedCoffeeScript 1.6.2d
(function() {
  var Entity, EntitySchema, INDEX_KEY, INDEX_NAME, INDEX_VAL, Neo, Setup, iced, redis, __iced_k, __iced_k_noop, _und,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  Setup = require('./setup');

  Neo = require('./neo');

  redis = Setup.db.redis;

  INDEX_NAME = 'node';

  INDEX_KEY = 'type';

  INDEX_VAL = 'entity';

  EntitySchema = {
    imgURL: '',
    name: 'Name of entity',
    description: '',
    type: '',
    tags: ['']
  };

  module.exports = Entity = (function(_super) {
    __extends(Entity, _super);

    function Entity(_node) {
      this._node = _node;
      Entity.__super__.constructor.call(this, this._node);
    }

    Entity.prototype.vote = function(attr, voteLink, cb) {
      var downVote, err, rel, upVote, voteTally, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "entity.coffee",
          funcname: "Entity.vote"
        });
        _this._node.createRelationshipTo(attr._node, voteLink.name, voteLink.data, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return rel = arguments[1];
            };
          })(),
          lineno: 30
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          return cb(err);
        }
        redis.incr("entity:" + _this._node.id + "::attr:" + attr._node.id + "::" + voteLink.data.type);
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "entity.coffee",
            funcname: "Entity.vote"
          });
          redis.get("entity:" + _this._node.id + "::attr:" + attr._node.id + "::pos", __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                err = arguments[0];
                return upVote = arguments[1];
              };
            })(),
            lineno: 36
          }));
          __iced_deferrals._fulfill();
        })(function() {
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "entity.coffee",
              funcname: "Entity.vote"
            });
            redis.get("entity:" + _this._node.id + "::attr:" + attr._node.id + "::neg", __iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  err = arguments[0];
                  return downVote = arguments[1];
                };
              })(),
              lineno: 37
            }));
            __iced_deferrals._fulfill();
          })(function() {
            voteTally = {
              upVote: upVote || 0,
              downVote: downVote || 0
            };
            return cb(null, voteTally);
          });
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


  Entity.deserialize = function(data) {
    return Neo.deserialize(EntitySchema, data);
  };

  Entity.create = function(reqBody, cb) {
    var index;
    index = {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: INDEX_KEY,
      INDEX_VAL: INDEX_VAL
    };
    return Neo.create(Entity, reqBody, index, cb);
  };

  Entity.get = function(id, cb) {
    return Neo.get(Entity, id, cb);
  };

  Entity.getOrCreate = function(reqBody, cb) {
    if (reqBody['id']) {
      return Entity.get(reqBody['id'], cb);
    } else {
      return Entity.create(reqBody, cb);
    }
  };

  Entity.put = function(nodeId, reqBody, cb) {
    return Neo.put(Entity, nodeId, reqBody, cb);
  };

}).call(this);

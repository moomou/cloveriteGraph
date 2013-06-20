// Generated by IcedCoffeeScript 1.6.2d
(function() {
  var Attribute, AttributeSchema, INDEX_KEY, INDEX_NAME, INDEX_VAL, Neo, Setup, iced, redis, __iced_k, __iced_k_noop, _und,
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

  INDEX_VAL = 'attribute';

  AttributeSchema = {
    name: 'Name of attribute',
    description: '',
    type: '',
    tags: ['']
  };

  module.exports = Attribute = (function(_super) {
    __extends(Attribute, _super);

    function Attribute(_node) {
      this._node = _node;
      Attribute.__super__.constructor.call(this, this._node);
    }

    Attribute.prototype.serialize = function(cb, entityId) {
      var downVote, err, upVote, voteTally, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      if (!entityId) {
        return Attribute.__super__.serialize.call(this, cb, null);
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "attribute.coffee",
          funcname: "Attribute.serialize"
        });
        redis.get("entity:" + entityId + "::attr:" + _this._node.id + "::pos", __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return upVote = arguments[1];
            };
          })(),
          lineno: 29
        }));
        redis.get("entity:" + entityId + "::attr:" + _this._node.id + "::neg", __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return downVote = arguments[1];
            };
          })(),
          lineno: 30
        }));
        __iced_deferrals._fulfill();
      })(function() {
        voteTally = {
          upVote: upVote || 0,
          downVote: downVote || 0
        };
        return Attribute.__super__.serialize.call(_this, cb, voteTally);
      });
    };

    return Attribute;

  })(Neo);

  /*
  Static Method
  */


  Attribute.deserialize = function(data) {
    return Neo.deserialize(AttributeSchema, data);
  };

  Attribute.create = function(reqBody, cb) {
    var index;
    index = {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: INDEX_KEY,
      INDEX_VAL: INDEX_VAL
    };
    return Neo.create(Attribute, reqBody, index, cb);
  };

  Attribute.get = function(id, cb) {
    return Neo.get(Attribute, id, cb);
  };

  Attribute.getOrCreate = function(reqBody, cb) {
    if (reqBody['id']) {
      return Attribute.get(reqBody['id'], cb);
    } else {
      return Attribute.create(reqBody, cb);
    }
  };

  Attribute.put = function(nodeId, reqBody, cb) {
    return Neo.put(Attribute, nodeId, reqBody, cb);
  };

}).call(this);

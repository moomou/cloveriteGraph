// Generated by IcedCoffeeScript 1.6.2d
(function() {
  var Attribute, AttributeSchema, INDEX_NAME, Indexes, Neo, Setup, iced, redis, __iced_k, __iced_k_noop, _und,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  Setup = require('./setup');

  Neo = require('./neo');

  redis = Setup.db.redis;

  INDEX_NAME = 'nAttribute';

  Indexes = [
    {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'name',
      INDEX_VALUE: ''
    }, {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'description',
      INDEX_VALUE: ''
    }, {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'type',
      INDEX_VALUE: ''
    }
  ];

  AttributeSchema = {
    name: 'Name of attribute',
    description: '',
    type: '',
    tone: 'pos'
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
          lineno: 44
        }));
        redis.get("entity:" + entityId + "::attr:" + _this._node.id + "::neg", __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return downVote = arguments[1];
            };
          })(),
          lineno: 45
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


  Attribute.Name = 'nAttribute';

  Attribute.INDEX_NAME = INDEX_NAME;

  Attribute.deserialize = function(data) {
    return Neo.deserialize(AttributeSchema, data);
  };

  Attribute.create = function(reqBody, cb) {
    return Neo.create(Attribute, reqBody, Indexes, cb);
  };

  Attribute.get = function(id, cb) {
    return Neo.get(Attribute, id, cb);
  };

  Attribute.getOrCreate = function(reqBody, cb) {
    return Neo.getOrCreate(Attribute, reqBody, cb);
  };

  Attribute.put = function(nodeId, reqBody, cb) {
    return Neo.put(Attribute, nodeId, reqBody, cb);
  };

}).call(this);

/*
//@ sourceMappingURL=attribute.map
*/

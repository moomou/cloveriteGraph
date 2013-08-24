// Generated by IcedCoffeeScript 1.6.2d
(function() {
  var INDEX_NAME, Indexes, Neo, Setup, Tag, TagSchema, redis, _und,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };



  _und = require('underscore');

  Setup = require('./setup');

  Neo = require('./neo');

  redis = Setup.db.redis;

  INDEX_NAME = 'nTag';

  Indexes = [
    {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'name',
      INDEX_VALUE: ''
    }
  ];

  TagSchema = {
    name: 'Name of Tag'
  };

  module.exports = Tag = (function(_super) {
    __extends(Tag, _super);

    function Tag(_node) {
      this._node = _node;
      Tag.__super__.constructor.call(this, this._node);
    }

    return Tag;

  })(Neo);

  /*
  Static Method
  */


  Tag.Name = 'nTag';

  Tag.INDEX_NAME = INDEX_NAME;

  Tag.Indexes = Indexes;

  Tag.deserialize = function(data) {
    return Neo.deserialize(TagSchema, data);
  };

  Tag.create = function(reqBody, cb) {
    return Neo.create(Tag, reqBody, Indexes, cb);
  };

  Tag.get = function(id, cb) {
    return Neo.get(Tag, id, cb);
  };

  Tag.getOrCreate = function(tagName, cb) {
    return Neo.getOrCreate(Tag, {
      name: tagName
    }, cb);
  };

  Tag.put = function(nodeId, reqBody, cb) {
    return Neo.put(Tag, nodeId, reqBody, cb);
  };

}).call(this);

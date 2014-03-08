// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var INDEX_NAME, Indexes, Logger, Neo, SchemaUtil, SchemaValidation, Slug, Tag, TagSchema, redis, _und,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };



  _und = require('underscore');

  redis = require('./setup').db.redis;

  Logger = require('../util/logger');

  Slug = require('../util/slug');

  Neo = require('./neo');

  SchemaUtil = require('./stdSchema');

  INDEX_NAME = 'nTag';

  Indexes = [
    {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'name',
      INDEX_VALUE: ''
    }, {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'slug',
      INDEX_VALUE: ''
    }
  ];

  TagSchema = {
    name: 'Name of Tag'
  };

  SchemaValidation = {
    name: SchemaUtil.required('string')
  };

  module.exports = Tag = (function(_super) {
    __extends(Tag, _super);

    function Tag(_node) {
      this._node = _node;
      Tag.__super__.constructor.call(this, this._node);
    }

    return Tag;

  })(Neo);

  Tag.Name = 'nTag';

  Tag.INDEX_NAME = INDEX_NAME;

  Tag.Indexes = Indexes;

  Tag.getSlugTitle = function(data) {
    return Slug.slugify(data.name);
  };

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
    Logger.debug("Tag getOrCreate cb: " + cb);
    return Neo.getOrCreate(Tag, {
      name: tagName
    }, cb);
  };

  Tag.put = function(nodeId, reqBody, cb) {
    return Neo.put(Tag, nodeId, reqBody, cb);
  };

}).call(this);

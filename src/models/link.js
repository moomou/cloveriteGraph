// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Constants, INDEX_NAME, Indexes, Link, LinkSchema, Logger, Neo, SchemaValidation, Slug, redis, _und,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };



  _und = require('underscore');

  redis = require('./setup').db.redis;

  Logger = require('../util/logger');

  Slug = require('../util/slug');

  Constants = require('../config').Constants;

  Neo = require('./neo');

  INDEX_NAME = 'rLink';

  Indexes = [
    {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'startend',
      INDEX_VALUE: ''
    }
  ];

  LinkSchema = {
    disabled: false,
    veracity: 0
  };

  SchemaValidation = {};

  module.exports = Link = (function(_super) {
    __extends(Link, _super);

    function Link(_node) {
      this._node = _node;
      Link.__super__.constructor.call(this, this._node);
    }

    return Link;

  })(Neo);


  /*
  Static Method
  */

  Link.Name = 'rLink';

  Link.INDEX_NAME = INDEX_NAME;

  Link.getSlugTitle = function(data) {
    if (data.name) {
      return Slug.slugify(data.name);
    } else {
      return "";
    }
  };

  Link.deserialize = function(data) {
    return Neo.deserialize(LinkSchema, data);
  };

  Link.normalizeName = function(name) {
    return "_" + (name.toUpperCase());
  };

  Link.normalizeData = function(linkData) {
    return Link.deserialize(linkData);
  };

  Link.index = function(rel, reqBody, cb) {
    if (cb == null) {
      cb = null;
    }
    return Neo.index(rel, Indexes, reqBody, cb);
  };

  Link.fillMetaData = function(linkData) {
    linkData = _und.clone(linkData);
    _und.extend(linkData, Neo.MetaSchema);
    linkData.createdAt = linkData.modifiedAt = new Date().getTime() / 1000;
    linkData.version += 1;
    return linkData;
  };

  Link.find = function(key, value, cb) {
    return Neo.findRel(Link, Link.INDEX_NAME, key, value, cb);
  };

  Link.get = function(id, cb) {
    return Neo.getRel(Link, id, cb);
  };

  Link.put = function(relId, reqBody, cb) {
    return Neo.put(Link, relId, reqBody, cb);
  };

  Link.create = function(reqBody, cb) {
    var linkData, linkName, res;
    linkName = Link.normalizeName(reqBody['name']);
    linkData = Link.normalizeData(reqBody['data']);
    res = {
      name: linkName,
      data: linkData
    };
    if (cb) {
      return cb(null, res);
    } else {
      return res;
    }
  };

}).call(this);

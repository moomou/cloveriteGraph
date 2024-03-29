// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Constants, INDEX_NAME, Indexes, Logger, Neo, Rank, RankSchema, Slug, _und,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };



  _und = require('underscore');

  Logger = require('../util/logger');

  Slug = require('../util/slug');

  Constants = require('../config').Constants;

  Neo = require('./neo');

  INDEX_NAME = 'rRank';

  Indexes = [
    {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'rank',
      INDEX_VALUE: ''
    }, {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'rankingName',
      INDEX_VALUE: ''
    }
  ];

  RankSchema = {
    rank: -1,
    collectionName: 'New Ranking'
  };

  module.exports = Rank = (function(_super) {
    __extends(Rank, _super);

    function Rank(_node) {
      this._node = _node;
      Rank.__super__.constructor.call(this, this._node);
    }

    return Rank;

  })(Neo);


  /*
  Static Method
  */

  Rank.Name = 'rRank';

  Rank.INDEX_NAME = INDEX_NAME;

  Rank.getSlugTitle = function(data) {
    if (data.name) {
      return Slug.slugify(data.name);
    } else {
      return "";
    }
  };

  Rank.deserialize = function(data) {
    return Neo.deserialize(RankSchema, data);
  };

  Rank.index = function(rel, reqBody, cb) {
    if (cb == null) {
      cb = null;
    }
    return Neo.index(rel, Indexes, reqBody, cb);
  };

  Rank.find = function(key, value, cb) {
    return Neo.findRel(Rank, Rank.INDEX_NAME, key, value, cb);
  };

  Rank.get = function(id, cb) {
    return Neo.getRel(Rank, id, cb);
  };

  Rank.put = function(relId, reqBody, cb) {
    return Neo.putRel(Rank, relId, reqBody, cb);
  };

}).call(this);

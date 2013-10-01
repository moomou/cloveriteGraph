// Generated by IcedCoffeeScript 1.6.3-e

/* ranking coffee
# user -ranking_link-> rank -> E1, E2
#       {
#       }
#                      {
#                       rankId: #search term or specific tag user sets
#                      }
*/

(function() {
  var INDEX_NAME, Indexes, Logger, Neo, Ranking, RankingSchema, SchemaUtil, SchemaValidation, Setup, redis, _und,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };



  _und = require('underscore');

  Logger = require('util');

  Setup = require('./setup');

  Neo = require('./neo');

  redis = Setup.db.redis;

  SchemaUtil = require('./stdSchema');

  INDEX_NAME = 'nRanking';

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

  RankingSchema = {
    name: 'New Ranking',
    description: '',
    type: '',
    tone: 'positive',
    next: 1
  };

  SchemaValidation = {};

  module.exports = Ranking = (function(_super) {
    __extends(Ranking, _super);

    function Ranking(_node) {
      this._node = _node;
      Ranking.__super__.constructor.call(this, this._node);
    }

    return Ranking;

  })(Neo);


  /*
  Static Method
  */

  Ranking.Name = 'nRanking';

  Ranking.INDEX_NAME = INDEX_NAME;

  Ranking.Indexes = Indexes;

  Ranking.validateSchema = function(data) {
    return SchemaUtil.validate(SchemaValidation, data);
  };

  Ranking.deserialize = function(data) {
    return Neo.deserialize(RankingSchema, data);
  };

  Ranking.create = function(reqBody, cb) {
    return Neo.create(Ranking, reqBody, Indexes, cb);
  };

  Ranking.get = function(id, cb) {
    return Neo.get(Ranking, id, cb);
  };

  Ranking.getOrCreate = function(reqBody, cb) {
    Logger.debug("Ranking getOrCreate");
    return Neo.getOrCreate(Ranking, reqBody, cb);
  };

  Ranking.put = function(nodeId, reqBody, cb) {
    return Neo.put(Ranking, nodeId, reqBody, cb);
  };

}).call(this);

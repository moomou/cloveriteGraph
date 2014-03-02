// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Attribute, Constants, Cypher, CypherBuilder, CypherLinkUtil, Data, DataRoute, Entity, EntityUtil, ErrorDevMessage, Link, Logger, Neo, Permission, Remote, Response, Tag, User, Vote, iced, redis, __iced_k, __iced_k_noop, _show, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  redis = require('../models/setup').db.redis;

  Logger = require('util');

  Remote = require('../remote/remote');

  Neo = require('../models/neo');

  User = require('../models/user');

  Entity = require('../models/entity');

  Attribute = require('../models/attribute');

  Data = require('../models/data');

  Tag = require('../models/tag');

  Vote = require('../models/vote');

  Link = require('../models/link');

  Constants = require('../config').Constants;

  EntityUtil = require('./entity/util');

  DataRoute = require('./data');

  Cypher = require('./util/cypher');

  CypherBuilder = Cypher.CypherBuilder;

  CypherLinkUtil = Cypher.CypherLinkUtil;

  Response = require('./util/response');

  ErrorDevMessage = Response.ErrorDevMessage;

  Permission = require('./permission');

  _show = function(req, res, next) {
    var attrBlobs, dataBlobs, dataId, entity, entityId, err, ids, slugs, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    if (req.query.id) {
      slugs = req.query.id.split(" ").map(function() {
        return encodeURIComponent(slug);
      });
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "embed.coffee",
          funcname: "_show"
        });
        redis.hget(Constants.RedisKey.slugToId, slugs, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return ids = arguments[1];
            };
          })(),
          lineno: 43
        }));
        __iced_deferrals._fulfill();
      })(function() {
        (function(__iced_k) {
          var _ref;
          if (!result) {
            return __iced_k(Response.OKResponse(res)(404));
          } else {
            _ref = ids.split(","), entityId = _ref[0], dataId = _ref[1];
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                filename: "embed.coffee",
                funcname: "_show"
              });
              if (entityId) {
                Entity.get(req.params.id, __iced_deferrals.defer({
                  assign_fn: (function() {
                    return function() {
                      err = arguments[0];
                      return entity = arguments[1];
                    };
                  })(),
                  lineno: 52
                }));
              }
              if (dataId[0] === "a") {
                EntityUtil.getEntityAttributes(entity, __iced_deferrals.defer({
                  assign_fn: (function() {
                    return function() {
                      return attrBlobs = arguments[0];
                    };
                  })(),
                  lineno: 54
                }));
              } else {
                EntityUtil.getEntityData(entity, __iced_deferrals.defer({
                  assign_fn: (function() {
                    return function() {
                      return dataBlobs = arguments[0];
                    };
                  })(),
                  lineno: 56
                }));
              }
              __iced_deferrals._fulfill();
            })(__iced_k);
          }
        })(__iced_k);
      });
    } else {
      return __iced_k(Response.OKResponse(res)(200));
    }
  };

  exports.show = _show;

}).call(this);
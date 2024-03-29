// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Attribute, Constants, Cypher, CypherBuilder, CypherLinkUtil, Entity, Link, Logger, RedisKey, Tag, User, getUser, iced, isAdmin, redis, __iced_k, __iced_k_noop, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  redis = require('../models/setup').db.redis;

  Constants = require('../config').Constants;

  Logger = require('../util/logger');

  User = require('../models/user');

  Entity = require('../models/entity');

  Attribute = require('../models/attribute');

  Tag = require('../models/tag');

  Link = require('../models/link');

  Cypher = require('./util/cypher');

  CypherBuilder = Cypher.CypherBuilder;

  CypherLinkUtil = Cypher.CypherLinkUtil;

  RedisKey = require('../config').RedisKey;


  /*
  # Reads http header to get access token
  # Exchange this token for a user unique identifier
  # then return the raw neo4j node of the user
  */

  exports.getUser = getUser = function(req, cb) {
    var accessToken, err, neoUserId, user, ___iced_passed_deferral, __iced_deferrals, __iced_k, _ref,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    accessToken = (_ref = req.headers['x-access-token']) != null ? _ref : "none";
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "permission.coffee",
        funcname: "getUser"
      });
      redis.hget(accessToken, "id", __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return neoUserId = arguments[1];
          };
        })(),
        lineno: 31
      }));
      __iced_deferrals._fulfill();
    })(function() {
      err = user = null;
      if (!neoUserId) {
        Logger.debug("No such user");
        return cb(null, null);
      }
      Logger.debug("Utility.getUser " + neoUserId);
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "permission.coffee",
          funcname: "getUser"
        });
        User.get(neoUserId, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return user = arguments[1];
            };
          })(),
          lineno: 39
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          if (err) {
            return cb(err, null);
          }
        } else {
          return cb(null, user);
        }
      });
    });
  };


  /*
  # Permission Related Stuff
  */

  exports.isAdmin = isAdmin = function(accessToken, cb) {
    return redis.sismember(RedisKey.superToken, accessToken, function(err, res) {
      return cb(err, res);
    });
  };


  /*
  # High level function
  */

  exports.hasPermission = function(user, other, cb) {
    var err, isPrivate, path, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    if (!other) {
      return cb(null, false);
    }
    isPrivate = other._node.data["private"];
    if (!isPrivate) {
      return cb(null, true);
    }
    if (!user) {
      return cb(null, false);
    }
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "permission.coffee",
        funcname: "hasPermission"
      });
      CypherLinkUtil.hasLink(user._node, other._node, Constants.REL_ACCESS, "all", __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return path = arguments[1];
          };
        })(),
        lineno: 74
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return cb(err, null);
      } else {
        if (path) {
          return cb(null, true);
        } else {
          return cb(null, false);
        }
      }
    });
  };

  exports.authCurry = function(hasPermission) {
    return function(cb) {
      return function(req, res, next) {
        var augReq, err, errRes, ___iced_passed_deferral, __iced_deferrals, __iced_k,
          _this = this;
        __iced_k = __iced_k_noop;
        ___iced_passed_deferral = iced.findDeferral(arguments);
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "permission.coffee"
          });
          hasPermission(req, res, next, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                err = arguments[0];
                errRes = arguments[1];
                return augReq = arguments[2];
              };
            })(),
            lineno: 87
          }));
          __iced_deferrals._fulfill();
        })(function() {
          if (err) {
            return errRes;
          }
          return cb(augReq, res, next);
        });
      };
    };
  };

}).call(this);

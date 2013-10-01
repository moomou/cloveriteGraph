// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Attribute, Constants, Entity, Logger, Neo, Ranking, SchemaUtil, Tag, User, Utility, hasPermission, iced, redis, __iced_k, __iced_k_noop, _addNew, _create, _show, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  Logger = require('util');

  Neo = require('../models/neo');

  User = require('../models/user');

  Entity = require('../models/entity');

  Attribute = require('../models/attribute');

  Tag = require('../models/tag');

  Ranking = require('../models/ranking');

  SchemaUtil = require('../models/stdSchema');

  Constants = SchemaUtil.Constants;

  Utility = require('./utility');

  redis = require('../models/setup').db.redis;

  hasPermission = function(req, res, next, cb) {
    var err, errOther, errUser, other, reqWithUser, user, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "ranking.coffee",
        funcname: "hasPermission"
      });
      User.get(req.params.id, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errOther = arguments[0];
            return other = arguments[1];
          };
        })(),
        lineno: 21
      }));
      Utility.getUser(req, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errUser = arguments[0];
            return user = arguments[1];
          };
        })(),
        lineno: 22
      }));
      __iced_deferrals._fulfill();
    })(function() {
      err = errUser || errOther;
      if (err) {
        return cb(true, res.status(500).json({
          error: "Unable to retrieve from neo4j"
        }), req);
      }
      if (!other) {
        return cb(true, res.status(401).json({
          error: "Unable to retrieve from neo4j"
        }), req);
      }
      if (user) {
        user = user.serialize();
      }
      if (other) {
        other = other.serialize();
      }
      reqWithUser = _und.extend(_und.clone(req), {
        user: user
      });
      if (user && other && other.id === user.id) {
        return cb(false, null, reqWithUser);
      }
      return cb(true, res.status(401).json({
        error: "Unauthorized"
      }), req);
    });
  };

  exports.create = function(req, res, next) {
    var ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "ranking.coffee",
        funcname: "create"
      });
      hasPermission(req, res, next, refer(err, errRes, augReq));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return errRes;
      }
      return _create(augReq, res, next);
    });
  };

  _create = function(req, res, next) {
    var err, ranking, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "ranking.coffee",
        funcname: "_create"
      });
      Ranking.create(req.body, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return ranking = arguments[1];
          };
        })(),
        lineno: 53
      }));
      __iced_deferrals._fulfill();
    })(function() {
      Utility.createLink(req.user._node, ranking._node, Constants.REL_RANKING, {}, function(err, rel) {});
      return res.status(201).json(ranking.serialize());
    });
  };

  exports.show = function(req, res, next) {
    var ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "ranking.coffee",
        funcname: "show"
      });
      hasPermission(req, res, next, refer(err, errRes, augReq));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return errRes;
      }
      return _show(augReq, res, next);
    });
  };

  _show = function(req, res, next) {
    var err, ranking, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "ranking.coffee",
        funcname: "_show"
      });
      Ranking.get(req.params.rankingId, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return ranking = arguments[1];
          };
        })(),
        lineno: 70
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return next(err);
      }
      return res.json(ranking.serialize());
    });
  };

  exports.addNew = function(req, res, next) {
    var ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "ranking.coffee",
        funcname: "addNew"
      });
      hasPermission(req, res, next, refer(err, errRes, augReq));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return errRes;
      }
      if (!req.body.entity) {
        return res.status(400);
      }
      return _addNew(augReq, res, next);
    });
  };

  _addNew = function(req, res, next) {
    var entity, err, errE, errR, rankData, ranking, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "ranking.coffee",
        funcname: "_addNew"
      });
      Entity.get(req.body.entity, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errE = arguments[0];
            return entity = arguments[1];
          };
        })(),
        lineno: 84
      }));
      Ranking.get(req.params.rankingId, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errR = arguments[0];
            return ranking = arguments[1];
          };
        })(),
        lineno: 85
      }));
      __iced_deferrals._fulfill();
    })(function() {
      err = errE || errR;
      if (err) {
        return next(err);
      }
      rankData = new Rank(req.body);
      Utility.createLink(req.user._node, ranking._node, Constants.REL_RANK, rankData, function(err, rel) {});
      return res.status(201).json({});
    });
  };

}).call(this);

// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Attribute, Constants, Entity, Link, Logger, Neo, Response, StdSchema, Tag, User, Utility, Vote, hasPermission, iced, rest, __iced_k, __iced_k_noop, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  rest = require('restler');

  Logger = require('util');

  Neo = require('../models/neo');

  User = require('../models/user');

  Entity = require('../models/entity');

  Attribute = require('../models/attribute');

  Tag = require('../models/tag');

  Vote = require('../models/vote');

  Link = require('../models/link');

  StdSchema = require('../models/stdSchema');

  Constants = StdSchema.Constants;

  Response = StdSchema;

  Utility = require('./utility');

  hasPermission = function(req, cb) {
    var err, errOther, errUser, other, user, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "hasPermission"
      });
      User.get(req.params.id, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errOther = arguments[0];
            return other = arguments[1];
          };
        })(),
        lineno: 25
      }));
      Utility.getUser(req, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errUser = arguments[0];
            return user = arguments[1];
          };
        })(),
        lineno: 26
      }));
      __iced_deferrals._fulfill();
    })(function() {
      err = errUser || errOther;
      if (err) {
        return cb(new Error("Unable to retrieve from neo4j"), null);
      }
      if (!other) {
        return cb(null, false);
      }
      if (other._node.data.id === other._node.data.id) {
        return cb(null, true);
      }
      return Utility.hasPermission(user, other, cb);
    });
  };

  exports.getCreated = function(req, res, next) {
    var authorized, blobs, err, errUser, ind, node, nodes, user, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "getCreated"
      });
      hasPermission(req, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return authorized = arguments[1];
          };
        })(),
        lineno: 44
      }));
      Utility.getUser(req, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errUser = arguments[0];
            return user = arguments[1];
          };
        })(),
        lineno: 45
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (!authorized) {
        console.log("No Permission");
        return res.status(401).json({
          error: "Permission Denied"
        });
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "user.coffee",
          funcname: "getCreated"
        });
        user._node.getRelationshipNodes({
          type: Constants.REL_CREATED,
          direction: 'out'
        }, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return nodes = arguments[1];
            };
          })(),
          lineno: 53
        }));
        __iced_deferrals._fulfill();
      })(function() {
        var _i, _len;
        if (err) {
          return next(err);
        }
        blobs = [];
        for (ind = _i = 0, _len = nodes.length; _i < _len; ind = ++_i) {
          node = nodes[ind];
          blobs[ind] = (new Entity(node)).serialize();
        }
        return res.json(blobs);
      });
    });
  };

  exports.getVoted = function(req, res, next) {
    var authorized, blobs, err, errUser, ind, node, nodes, user, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "getVoted"
      });
      hasPermission(req, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return authorized = arguments[1];
          };
        })(),
        lineno: 65
      }));
      Utility.getUser(req, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errUser = arguments[0];
            return user = arguments[1];
          };
        })(),
        lineno: 66
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (!authorized) {
        console.log("No Permission");
        return res.status(401).json({
          error: "Permission Denied"
        });
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "user.coffee",
          funcname: "getVoted"
        });
        user._node.getRelationshipNodes({
          type: Constants.REL_VOTED,
          direction: 'out'
        }, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return nodes = arguments[1];
            };
          })(),
          lineno: 74
        }));
        __iced_deferrals._fulfill();
      })(function() {
        var _i, _len;
        if (err) {
          return next(err);
        }
        blobs = [];
        for (ind = _i = 0, _len = nodes.length; _i < _len; ind = ++_i) {
          node = nodes[ind];
          blobs[ind] = (new Entity(node)).serialize();
        }
        return res.json(blobs);
      });
    });
  };

  exports.getCommented = function(req, res, next) {
    var authorized, blobs, err, errUser, ind, node, nodes, user, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "getCommented"
      });
      hasPermission(req, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return authorized = arguments[1];
          };
        })(),
        lineno: 86
      }));
      Utility.getUser(req, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errUser = arguments[0];
            return user = arguments[1];
          };
        })(),
        lineno: 87
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (!authorized) {
        console.log("No Permission");
        return res.status(401).json({
          error: "Permission Denied"
        });
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "user.coffee",
          funcname: "getCommented"
        });
        user._node.getRelationshipNodes({
          type: Constants.REL_COMMENTED,
          direction: 'out'
        }, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return nodes = arguments[1];
            };
          })(),
          lineno: 95
        }));
        __iced_deferrals._fulfill();
      })(function() {
        var _i, _len;
        if (err) {
          return next(err);
        }
        blobs = [];
        for (ind = _i = 0, _len = nodes.length; _i < _len; ind = ++_i) {
          node = nodes[ind];
          blobs[ind] = (new Entity(node)).serialize();
        }
        return res.json(blobs);
      });
    });
  };

}).call(this);

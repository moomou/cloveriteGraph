// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Attribute, Constants, Entity, Link, Response, StdSchema, Tag, User, createLink, createMultipleLinks, db, getStartEndIndex, getUser, hasLink, iced, isAdmin, redis, __iced_k, __iced_k_noop, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  StdSchema = require('../models/stdSchema');

  Constants = StdSchema.Constants;

  Response = StdSchema;

  User = require('../models/user');

  Entity = require('../models/entity');

  Attribute = require('../models/attribute');

  Tag = require('../models/tag');

  Link = require('../models/link');

  db = require('../models/setup').db;

  redis = require('../models/setup').db.redis;


  /*
  # Construct key
  */

  exports.getStartEndIndex = getStartEndIndex = function(start, rel, end) {
    return "" + start + "_" + rel + "_" + end;
  };


  /*
  # Finds the attribute given entity object
  */

  exports.getEntityAttributes = function(entity, cb) {
    var attrBlobs, blob, err, ind, linkData, node, nodes, rels, startendVal, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    rels = [];
    attrBlobs = [];
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "utility.coffee",
        funcname: "getEntityAttributes"
      });
      entity._node.getRelationshipNodes({
        type: Constants.REL_ATTRIBUTE,
        direction: 'in'
      }, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return nodes = arguments[1];
          };
        })(),
        lineno: 30
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return err;
      }
      (function(__iced_k) {
        var _i, _len;
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "utility.coffee",
          funcname: "getEntityAttributes"
        });
        for (ind = _i = 0, _len = nodes.length; _i < _len; ind = ++_i) {
          node = nodes[ind];
          startendVal = getStartEndIndex(node.id, Constants.REL_ATTRIBUTE, entity._node.id);
          Link.find('startend', startendVal, __iced_deferrals.defer({
            assign_fn: (function(__slot_1, __slot_2) {
              return function() {
                err = arguments[0];
                return __slot_1[__slot_2] = arguments[1];
              };
            })(rels, ind),
            lineno: 40
          }));
          (new Attribute(node)).serialize(__iced_deferrals.defer({
            assign_fn: (function(__slot_1, __slot_2) {
              return function() {
                return __slot_1[__slot_2] = arguments[0];
              };
            })(attrBlobs, ind),
            lineno: 41
          }), entity._node.id);
        }
        __iced_deferrals._fulfill();
      })(function() {
        var _i, _len;
        for (ind = _i = 0, _len = attrBlobs.length; _i < _len; ind = ++_i) {
          blob = attrBlobs[ind];
          if (rels[ind]) {
            linkData = {
              linkData: rels[ind].serialize()
            };
          } else {
            linkData = {
              linkData: {}
            };
          }
          _und.extend(blob, linkData);
        }
        console.log(attrBlobs);
        return cb(attrBlobs);
      });
    });
  };


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
    console.log("getUser");
    accessToken = (_ref = req.headers['access_token']) != null ? _ref : "none";
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "utility.coffee",
        funcname: "getUser"
      });
      redis.get(accessToken, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return neoUserId = arguments[1];
          };
        })(),
        lineno: 65
      }));
      __iced_deferrals._fulfill();
    })(function() {
      err = user = null;
      if (!neoUserId) {
        console.log("No such user");
        return cb(null, null);
      }
      console.log("Utility.getUser " + neoUserId);
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "utility.coffee",
          funcname: "getUser"
        });
        User.get(neoUserId, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return user = arguments[1];
            };
          })(),
          lineno: 73
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          cb(err, null);
        }
        return cb(null, user);
      });
    });
  };


  /*
  # Checks if a particular link type exists between the two node
  */

  exports.hasLink = hasLink = function(startNode, otherNode, linkType, dir, cb) {
    if (dir == null) {
      dir = "all";
    }
    return startNode.path(otherNode, linkType, dir, 1, 'shortestPath', function(err, path) {
      if (err) {
        return cb(err, null);
      }
      if (path) {
        return cb(null, path);
      } else {
        return cb(null, false);
      }
    });
  };

  exports.createLink = createLink = function(startNode, otherNode, linkType, linkData, cb) {
    console.log("Creating linkType: " + linkType);
    return startNode.createRelationshipTo(otherNode, linkType, linkData, function(err, link) {
      if (err) {
        return cb(new Error("Unable to create link"), null);
      }
      return cb(null, link);
    });
  };


  /*
  # Create multiple link with the same linkdata
  */

  exports.createMultipleLinks = createMultipleLinks = function(startNode, otherNode, links, linkData, cb) {
    var err, errs, ind, link, rels, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    errs = [];
    rels = [];
    (function(__iced_k) {
      var _i, _len;
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "utility.coffee",
        funcname: "createMultipleLinks"
      });
      for (ind = _i = 0, _len = links.length; _i < _len; ind = ++_i) {
        link = links[ind];
        createLink(startNode, otherNode, link, linkData, __iced_deferrals.defer({
          assign_fn: (function(__slot_1, __slot_2, __slot_3, __slot_4) {
            return function() {
              __slot_1[__slot_2] = arguments[0];
              return __slot_3[__slot_4] = arguments[1];
            };
          })(errs, ind, rels, ind),
          lineno: 116
        }));
      }
      __iced_deferrals._fulfill();
    })(function() {
      err = _und.find(errs, function(err) {
        return err;
      });
      return cb(err, rels);
    });
  };


  /*
  # Permission Related Stuff
  */

  exports.isAdmin = isAdmin = function(accessToken, cb) {
    return redis.sismember("superToken", accessToken, function(err, res) {
      return cb(err, res);
    });
  };


  /* High level function
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
        filename: "utility.coffee",
        funcname: "hasPermission"
      });
      hasLink(user._node, other._node, Constants.REL_ACCESS, "all", __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return path = arguments[1];
          };
        })(),
        lineno: 149
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (!path) {
        return cb(null, false);
      } else {
        return cb(null, true);
      }
    });
  };


  /*
  # Internal API for creating userNode
  */

  exports.createUser = function(req, res, next) {
    var accessToken, userToken;
    console.log("In Create user");
    accessToken = req.headers['access_token'];
    console.log(accessToken);
    userToken = req.body.userToken;
    console.log(userToken);
    return isAdmin(accessToken, function(err, isSuperAwesome) {
      var err, user, userObj, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      if (isSuperAwesome) {
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "utility.coffee"
          });
          User.create(__iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                err = arguments[0];
                return user = arguments[1];
              };
            })(),
            lineno: 170
          }));
          __iced_deferrals._fulfill();
        })(function() {
          userObj = user.serialize();
          redis.set(userToken, userObj.id);
          if (err) {
            return res.json({
              error: err
            });
          }
          return res.json(userObj);
          return __iced_k();
        });
      } else {
        return __iced_k(res.status(403).json({
          error: "Permission Denied"
        }));
      }
    });
  };

}).call(this);

// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Attribute, Collection, Constants, Entity, ErrorDevMessage, Logger, Permission, Recommendation, Request, Response, Tag, User, addToFeed, basicAuthentication, basicFeedGetter, basicFeedSetter, crypto, getFeed, getLinkType, hasPermission, iced, redis, __iced_k, __iced_k_noop, _getUser, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  crypto = require('crypto');

  redis = require('../models/setup').db.redis;

  Logger = require('../util/logger');

  Permission = require('./permission');

  User = require('../models/user');

  Entity = require('../models/entity');

  Attribute = require('../models/attribute');

  Tag = require('../models/tag');

  Request = require('../models/request');

  Recommendation = require('../models/recommendation');

  Collection = require('../models/collection');

  Constants = require('../config').Constants;

  Response = require('./util/response');

  ErrorDevMessage = Response.ErrorDevMessage;

  hasPermission = function(req, res, next, cb) {
    var ErrorResponse, errOther, errUser, isPublic, other, reqWithUsers, user, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    ErrorResponse = Response.ErrorResponse(res);
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
        lineno: 28
      }));
      Permission.getUser(req, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errUser = arguments[0];
            return user = arguments[1];
          };
        })(),
        lineno: 29
      }));
      __iced_deferrals._fulfill();
    })(function() {
      isPublic = req.params.id === "public";
      if (errUser || errOther) {
        return cb(true, ErrorResponse(500, ErrorDevMessage.dbIssue()), null);
      }
      if (!other) {
        return cb(true, ErrorResponse(400, ErrorDevMessage.customMsg("Requested user " + req.params.id + " does not exist.")), null);
      }
      reqWithUsers = _und.extend(_und.clone(req), {
        requestedUser: other,
        self: user
      });
      if (user && other && other._node.id === user._node.id) {
        Logger.info("Private View");
        return cb(false, null, _und.extend(reqWithUsers, {
          authenticated: true
        }));
      } else {
        Logger.info("Public View");
        return cb(false, null, _und.extend(reqWithUsers, {
          authenticated: false
        }));
      }
    });
  };

  basicAuthentication = Permission.authCurry(hasPermission);

  getLinkType = function(linkType, NodeClass) {
    if (NodeClass == null) {
      NodeClass = Entity;
    }
    return function(req, res, next) {
      var blobs, errGetRelationship, ind, node, nodeObj, nodes, user, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      Logger.debug("Getting linkType: " + linkType);
      Logger.debug("req.authenticated: " + req.authenticated);
      user = req.requestedUser;
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "user.coffee"
        });
        user._node.getRelationshipNodes({
          type: linkType,
          direction: 'out'
        }, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              errGetRelationship = arguments[0];
              return nodes = arguments[1];
            };
          })(),
          lineno: 68
        }));
        __iced_deferrals._fulfill();
      })(function() {
        var _i, _len;
        if (errGetRelationship) {
          return next(errGetRelationship);
        }
        blobs = [];
        for (ind = _i = 0, _len = nodes.length; _i < _len; ind = ++_i) {
          node = nodes[ind];
          nodeObj = new NodeClass(node);
          if (!req.authenticated && nodeObj._node.data["private"]) {
            continue;
          }
          blobs.push(nodeObj.serialize());
        }
        return Response.OKResponse(res)(200, blobs);
      });
    };
  };

  getFeed = function(userId, feedType, cb) {
    var err, feedId, feeds, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    feedId = "user:" + userId + ":" + feedType;
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "getFeed"
      });
      redis.lrange(feedId, 0, -1, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return feeds = arguments[1];
          };
        })(),
        lineno: 86
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return cb(true, null);
      }
      return cb(null, _und.map(feeds, function(feed) {
        return JSON.parse(feed);
      }));
    });
  };

  addToFeed = function(userId, newFeed, feedType, cb) {
    var err, feedId, result, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    feedId = "user:" + userId + ":" + feedType;
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "addToFeed"
      });
      redis.lpush(feedId, JSON.stringify(newFeed), __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return result = arguments[1];
          };
        })(),
        lineno: 92
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (!result) {
        return cb(true, null);
      }
      return cb(null, newFeed);
    });
  };

  basicFeedGetter = function(feedType) {
    return function(req, res, next) {
      var err, feed, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "user.coffee"
        });
        getFeed(req.params.id, feedType, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return feed = arguments[1];
            };
          })(),
          lineno: 99
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          return res.status(500).json({
            error: "getting " + feedType + " failed"
          });
        }
        return res.json(feed);
      });
    };
  };

  basicFeedSetter = function(FeedClass) {
    return function(req, res, next) {
      var cleanedFeed, err, receiver, result, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      cleanedFeed = FeedClass.fillMetaData(FeedClass.deserialize(req.body));
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "user.coffee"
        });
        User.find("username", cleandFeed.to, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return receiver = arguments[1];
            };
          })(),
          lineno: 108
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          return res.status(400).json({
            error: "No such user exist"
          });
        }
        receiver = receiver.serialize();
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "user.coffee"
          });
          addToFeed(receiver, cleanedFeed, FeedClass.name, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                err = arguments[0];
                return result = arguments[1];
              };
            })(),
            lineno: 113
          }));
          __iced_deferrals._fulfill();
        })(function() {
          if (err) {
            return res.status(500).json({
              error: "Storing " + FeedClass.name + " failed"
            });
          }
          return res.status(201).json({});
        });
      });
    };
  };


  /*
  # Internal API for creating userNode
  */

  exports.createUser = function(req, res, next) {
    var ErrorResponse, accessToken, buf, ex, userToken, valid, ___iced_passed_deferral, __iced_deferrals, __iced_k, _ref,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    Logger.debug("In Create user");
    ErrorResponse = Response.ErrorResponse(res);
    valid = User.validateSchema(req.body);
    if (!valid) {
      return ErrorResponse(400, ErrorDevMessage.dataValidationIssue("Missing required data"));
    }
    accessToken = (_ref = req.headers['x-access-token']) != null ? _ref : "none";
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "createUser"
      });
      crypto.randomBytes(16, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            ex = arguments[0];
            return buf = arguments[1];
          };
        })(),
        lineno: 132
      }));
      __iced_deferrals._fulfill();
    })(function() {
      userToken = buf.toString('hex');
      userToken = req.body.accessToken = "user_" + userToken;
      return Permission.isSuperAwesome(accessToken, function(err, isSuperAwesome) {
        var err, user, userObj, ___iced_passed_deferral1, __iced_deferrals, __iced_k,
          _this = this;
        __iced_k = __iced_k_noop;
        ___iced_passed_deferral1 = iced.findDeferral(arguments);
        if (isSuperAwesome) {
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral1,
              filename: "user.coffee"
            });
            User.create(req.body, __iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  err = arguments[0];
                  return user = arguments[1];
                };
              })(),
              lineno: 140
            }));
            __iced_deferrals._fulfill();
          })(function() {
            userObj = user.serialize();
            redis.hset(userToken, "id", userObj.id, function(err, result) {});
            return __iced_k(Response.OKResponse(res)(201, userObj));
          });
        } else {
          Logger.info("Non admin tried to create user!");
          return __iced_k(ErrorResponse(403, ErrorDevMessage.permissionIssue("Not admin")));
        }
      });
    });
  };

  exports.getCreated = basicAuthentication(getLinkType(Constants.REL_CREATED));

  exports.getVoted = basicAuthentication(getLinkType(Constants.REL_VOTED));

  exports.getCollection = basicAuthentication(getLinkType(Constants.REL_COLLECTION, Collection));

  _getUser = function(req, res, next) {
    var restricted;
    if (req.authenticated) {
      return Response.OKResponse(res)(200, req.requestedUser.serialize());
    } else {
      restricted = _und.omit(req.requestedUser.serialize(), "accessToken", "reputation");
      return Response.OKResponse(res)(200, restricted);
    }
  };

  exports.getUser = basicAuthentication(function(req, res, next) {
    if (req.params.id === "self") {
      return Response.OKResponse(res)(200, req.self.serialize());
    } else {
      return _getUser(req, res, next);
    }
  });

}).call(this);

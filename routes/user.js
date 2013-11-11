// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Attribute, Constants, Entity, Logger, Ranking, Recommendation, Request, SchemaUtil, Tag, User, Utility, addToFeed, basicAuthentication, basicFeedGetter, basicFeedSetter, crypto, getFeed, getLinkType, hasPermission, iced, redis, __iced_k, __iced_k_noop, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  crypto = require('crypto');

  Logger = require('util');

  User = require('../models/user');

  Entity = require('../models/entity');

  Attribute = require('../models/attribute');

  Tag = require('../models/tag');

  Request = require('../models/request');

  Recommendation = require('../models/recommendation');

  Ranking = require('../models/ranking');

  SchemaUtil = require('../models/stdSchema');

  Constants = SchemaUtil.Constants;

  Utility = require('./utility');

  redis = require('../models/setup').db.redis;

  hasPermission = function(req, res, next, cb) {
    var err, errOther, errUser, isPublic, other, reqWithUser, user, ___iced_passed_deferral, __iced_deferrals, __iced_k,
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
        lineno: 23
      }));
      Utility.getUser(req, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errUser = arguments[0];
            return user = arguments[1];
          };
        })(),
        lineno: 24
      }));
      __iced_deferrals._fulfill();
    })(function() {
      isPublic = req.params.id === "public";
      err = errUser || errOther;
      if (err) {
        return cb(true, res.status(500).json({
          error: "Unable to retrieve from neo4j"
        }), null);
      }
      if (!other) {
        return cb(true, res.status(401).json({
          error: "Unable to retrieve from neo4j"
        }), null);
      }
      if (isPublic) {
        reqWithUser = _und.extend(_und.clone(req), {
          user: other
        });
      } else {
        reqWithUser = _und.extend(_und.clone(req), {
          user: user
        });
      }
      if (user && other && other._node.id === user._node.id) {
        return cb(false, null, reqWithUser);
      }
      return cb(true, res.status(401).json({
        error: "Unauthorized"
      }), null);
    });
  };

  getLinkType = function(linkType, NodeClass) {
    if (NodeClass == null) {
      NodeClass = Entity;
    }
    return function(req, res, next) {
      var blobs, errGetRelationship, ind, node, nodes, user, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      Logger.debug("Getting linkType: " + linkType);
      user = req.user;
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
          lineno: 56
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
          blobs[ind] = (new NodeClass(node)).serialize();
        }
        return res.json(blobs);
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
        lineno: 68
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
        lineno: 74
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (!result) {
        return cb(true, null);
      }
      return cb(null, newFeed);
    });
  };

  basicAuthentication = Utility.authCurry(hasPermission);

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
          lineno: 83
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
          lineno: 92
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
            lineno: 97
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
    var accessToken, buf, ex, userToken, valid, ___iced_passed_deferral, __iced_deferrals, __iced_k, _ref,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    console.log("In Create user");
    valid = User.validateSchema(req.body);
    if (!valid) {
      return res.status(400).json({
        error: "Invalid input",
        input: req.body
      });
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
        lineno: 112
      }));
      __iced_deferrals._fulfill();
    })(function() {
      userToken = buf.toString('hex');
      userToken = req.body.accessToken = "user_" + userToken;
      return Utility.isAdmin(accessToken, function(err, isSuperAwesome) {
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
              lineno: 120
            }));
            __iced_deferrals._fulfill();
          })(function() {
            userObj = user.serialize();
            return __iced_k(redis.set(userToken, userObj.id, function(err, result) {
              if (err) {
                return res.json({
                  error: err
                });
              }
              return res.status(201).json(userObj);
            }));
          });
        } else {
          console.log("You are not awesome.");
          return __iced_k(res.status(403).json({
            error: "Permission Denied"
          }));
        }
      });
    });
  };

  exports.getDiscussion = basicAuthentication(basicFeedGetter("discussionFeed"));

  exports.getRecommendation = basicAuthentication(basicFeedGetter("recommendationFeed"));

  exports.getRequest = basicAuthentication(basicFeedGetter("requestFeed"));

  exports.sendRecommendation = basicAuthentication(basicFeedSetter(Recommendation));

  exports.sendRequest = basicAuthentication(basicFeedSetter(Request));

  exports.getCreated = basicAuthentication(getLinkType(Constants.REL_CREATED));

  exports.getVoted = basicAuthentication(getLinkType(Constants.REL_VOTED));

  exports.getCommented = basicAuthentication(getLinkType(Constants.REL_COMMENTED));

  exports.getRanked = basicAuthentication(getLinkType(Constants.REL_RANKING, Ranking));

  exports.getSelf = basicAuthentication(function(req, res, next) {
    var err, user, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee"
      });
      User.get(req.params.id, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return user = arguments[1];
          };
        })(),
        lineno: 159
      }));
      __iced_deferrals._fulfill();
    })(function() {
      return res.json(user.serialize());
    });
  });

}).call(this);

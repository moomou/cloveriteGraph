// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Attribute, Constants, Entity, Logger, Neo, Recommendation, Request, SchemaUtil, Tag, User, Utility, addToFeed, getFeed, getLinkType, hasPermission, iced, redis, __iced_k, __iced_k_noop, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  Logger = require('util');

  Neo = require('../models/neo');

  User = require('../models/user');

  Entity = require('../models/entity');

  Attribute = require('../models/attribute');

  Tag = require('../models/tag');

  Request = require('../models/request');

  Recommendation = require('../models/recommendation');

  SchemaUtil = require('../models/stdSchema');

  Constants = SchemaUtil.Constants;

  Utility = require('./utility');

  redis = require('../models/setup').db.redis;

  hasPermission = function(req, res, next, cb) {
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
        lineno: 24
      }));
      Utility.getUser(req, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errUser = arguments[0];
            return user = arguments[1];
          };
        })(),
        lineno: 25
      }));
      __iced_deferrals._fulfill();
    })(function() {
      err = errUser || errOther;
      if (err) {
        return cb(true, res.status(500).json({
          error: "Unable to retrieve from neo4j"
        }));
      }
      if (!other) {
        return cb(true, res.status(401).json({
          error: "Unable to retrieve from neo4j"
        }));
      }
      if (user) {
        user = user.serialize();
      }
      if (other) {
        other = other.serialize();
      }
      if (user && other && other.id === user.id) {
        return cb(false, null);
      }
      return cb(true, res.status(401).json({
        error: "Unauthorized"
      }));
    });
  };

  getLinkType = function(req, res, next, linkType) {
    var blobs, errGetRelationship, errUser, ind, node, nodes, user, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "getLinkType"
      });
      Utility.getUser(req, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errUser = arguments[0];
            return user = arguments[1];
          };
        })(),
        lineno: 43
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (errUser || !user) {
        return next(errUser);
      }
      Logger.debug("Getting linkType: " + linkType);
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "user.coffee",
          funcname: "getLinkType"
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
          lineno: 50
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
          blobs[ind] = (new Entity(node)).serialize();
        }
        return res.json(blobs);
      });
    });
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
        lineno: 62
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
        lineno: 68
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (!result) {
        return cb(true, null);
      }
      return cb(null, newFeed);
    });
  };

  exports.getDiscussion = function(req, res, next) {
    var discussionFeed, err, errRes, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "getDiscussion"
      });
      hasPermission(req, res, next, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return errRes = arguments[1];
          };
        })(),
        lineno: 74
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return errRes;
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "user.coffee",
          funcname: "getDiscussion"
        });
        getFeed(req.params.id, "discussionFeed", __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return discussionFeed = arguments[1];
            };
          })(),
          lineno: 76
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          return res.status(500).json({
            error: "get discussion failed"
          });
        }
        return res.json(discussionFeed);
      });
    });
  };

  exports.getRecommendation = function(req, res, next) {
    var err, errRes, recommendationFeed, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "getRecommendation"
      });
      hasPermission(req, res, next, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return errRes = arguments[1];
          };
        })(),
        lineno: 82
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return errRes;
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "user.coffee",
          funcname: "getRecommendation"
        });
        getFeed(req.params.id, "recommendationFeed", __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return recommendationFeed = arguments[1];
            };
          })(),
          lineno: 84
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          return res.status(500).json({
            error: "get recommendationFeed failed"
          });
        }
        return res.json(recommendationFeed);
      });
    });
  };

  exports.getRequest = function(req, res, next) {
    var err, errRes, requestFeed, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "getRequest"
      });
      hasPermission(req, res, next, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return errRes = arguments[1];
          };
        })(),
        lineno: 90
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return errRes;
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "user.coffee",
          funcname: "getRequest"
        });
        getFeed(req.params.id, "requestFeed", __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return requestFeed = arguments[1];
            };
          })(),
          lineno: 92
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          return res.status(500).json({
            error: "get requestFeed"
          });
        }
        return res.json(requestFeed);
      });
    });
  };

  exports.sendRecommendation = function(req, res, next) {
    var cleanedRecommendation, err, errRes, receiver, result, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "sendRecommendation"
      });
      hasPermission(req, res, next, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return errRes = arguments[1];
          };
        })(),
        lineno: 98
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return errRes;
      }
      cleanedRecommendation = Recommendation.fillMetaData(Recommendation.deserialize(req.body));
      console.log(cleanedRecommendation);
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "user.coffee",
          funcname: "sendRecommendation"
        });
        User.find("username", cleanedRecommendation.to, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return receiver = arguments[1];
            };
          })(),
          lineno: 104
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
            filename: "user.coffee",
            funcname: "sendRecommendation"
          });
          addToFeed(receiver, cleanedRecommendation, "recommendationFeed", __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                err = arguments[0];
                return result = arguments[1];
              };
            })(),
            lineno: 109
          }));
          __iced_deferrals._fulfill();
        })(function() {
          if (err) {
            return res.status(500).json({
              error: "post recommendationFeed"
            });
          }
          return res.status(201).json({});
        });
      });
    });
  };

  exports.sendRequest = function(req, res, next) {
    var cleanedRequest, err, errRes, receiver, result, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "sendRequest"
      });
      hasPermission(req, res, next, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return errRes = arguments[1];
          };
        })(),
        lineno: 115
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return errRes;
      }
      cleanedRequest = Request.fillMetaData(Request.deserialize(req.body));
      console.log(cleanedRequest);
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "user.coffee",
          funcname: "sendRequest"
        });
        User.find("username", cleanedRequest.to, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return receiver = arguments[1];
            };
          })(),
          lineno: 121
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
            filename: "user.coffee",
            funcname: "sendRequest"
          });
          addToFeed(receiver.id, cleanedRequest, "requestFeed", __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                err = arguments[0];
                return result = arguments[1];
              };
            })(),
            lineno: 126
          }));
          __iced_deferrals._fulfill();
        })(function() {
          if (err) {
            return res.status(500).json({
              error: "post requestFeed"
            });
          }
          return res.status(201).json({});
        });
      });
    });
  };

  exports.getCreated = function(req, res, next) {
    var err, errRes, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "getCreated"
      });
      hasPermission(req, res, next, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return errRes = arguments[1];
          };
        })(),
        lineno: 132
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return errRes;
      }
      return getLinkType(req, res, next, Constants.REL_CREATED);
    });
  };

  exports.getVoted = function(req, res, next) {
    var err, errRes, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "getVoted"
      });
      hasPermission(req, res, next, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return errRes = arguments[1];
          };
        })(),
        lineno: 138
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return errRes;
      }
      return getLinkType(req, res, next, Constants.REL_VOTED);
    });
  };

  exports.getCommented = function(req, res, next) {
    var err, errRes, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "getCommented"
      });
      hasPermission(req, res, next, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return errRes = arguments[1];
          };
        })(),
        lineno: 144
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return errRes;
      }
      return getLinkType(req, res, next, Constants.REL_COMMENTED);
    });
  };

  exports.getSelf = function(req, res, next) {
    var err, errRes, user, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "user.coffee",
        funcname: "getSelf"
      });
      hasPermission(req, res, next, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return errRes = arguments[1];
          };
        })(),
        lineno: 150
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return errRes;
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "user.coffee",
          funcname: "getSelf"
        });
        User.get(req.params.id, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return user = arguments[1];
            };
          })(),
          lineno: 152
        }));
        __iced_deferrals._fulfill();
      })(function() {
        return res.json(user.serialize());
      });
    });
  };

}).call(this);

// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Attribute, Constants, Cypher, CypherBuilder, CypherLinkUtil, Entity, EntityUtil, ErrorDevMessage, Logger, Neo, Rank, Ranking, Response, SchemaUtil, Setup, Tag, User, Utility, basicAuthentication, db, hasPermission, iced, redis, __iced_k, __iced_k_noop, _create, _delete, _edit, _show, _showDetail, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  Logger = require('util');

  Setup = require('../models/setup');

  db = Setup.db;

  Neo = require('../models/neo');

  User = require('../models/user');

  Entity = require('../models/entity');

  Attribute = require('../models/attribute');

  Tag = require('../models/tag');

  Ranking = require('../models/ranking');

  Rank = require('../models/rank');

  SchemaUtil = require('../models/stdSchema');

  Constants = SchemaUtil.Constants;

  EntityUtil = require('./entity/util');

  Cypher = require('./cypher');

  CypherBuilder = Cypher.CypherBuilder;

  CypherLinkUtil = Cypher.CypherLinkUtil;

  Response = require('./response');

  ErrorDevMessage = Response.ErrorDevMessage;

  Utility = require('./utility');

  redis = require('../models/setup').db.redis;

  hasPermission = function(req, res, next, cb) {
    var ErrorResponse, err, errOther, errUser, isPublic, other, reqWithUser, user, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    ErrorResponse = Response.ErrorResponse(res);
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
        lineno: 37
      }));
      Utility.getUser(req, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errUser = arguments[0];
            return user = arguments[1];
          };
        })(),
        lineno: 38
      }));
      __iced_deferrals._fulfill();
    })(function() {
      isPublic = req.params.id === "public";
      err = errUser || errOther;
      if (err) {
        return cb(true, ErrorResponse(500, ErrorDevMessage.dbIssue()), null);
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
      if (isPublic || (user && other && other._node.id === user._node.id)) {
        return cb(false, null, reqWithUser);
      }
      if (!other) {
        return cb(true, ErrorResponse(500, ErrorDevMessage.dbIssue()), null);
      }
      return cb(true, ErrorResponse(401, ErrorDevMessage.permissionIssue()), null);
    });
  };

  basicAuthentication = Utility.authCurry(hasPermission);

  _create = function(req, res, next) {
    var entities, entity, err, errs, id, ind, ok, publicUser, rank, rankLinks, ranking, shareToken, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    if (!req.body.name || !req.body.ranks) {
      return Response.ErrorResponse(res)(400, ErrorDevMessage.missingParam("name or rank"));
    }
    console.log(req.user);
    req.body.createdBy = req.user._node.data.username;
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
        lineno: 73
      }));
      __iced_deferrals._fulfill();
    })(function() {
      CypherLinkUtil.getOrCreateLink(Rank, req.user._node, ranking._node, Constants.REL_RANKING, {}, function(err, rel) {});
      errs = [];
      entities = [];
      (function(__iced_k) {
        var _i, _len, _ref;
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "ranking.coffee",
          funcname: "_create"
        });
        _ref = ranking.serialize().ranks;
        for (ind = _i = 0, _len = _ref.length; _i < _len; ind = ++_i) {
          id = _ref[ind];
          Entity.get(id, __iced_deferrals.defer({
            assign_fn: (function(__slot_1, __slot_2, __slot_3, __slot_4) {
              return function() {
                __slot_1[__slot_2] = arguments[0];
                return __slot_3[__slot_4] = arguments[1];
              };
            })(errs, ind, entities, ind),
            lineno: 86
          }));
        }
        __iced_deferrals._fulfill();
      })(function() {
        errs = [];
        rankLinks = [];
        (function(__iced_k) {
          var _i, _len;
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "ranking.coffee",
            funcname: "_create"
          });
          for (rank = _i = 0, _len = entities.length; _i < _len; rank = ++_i) {
            entity = entities[rank];
            CypherLinkUtil.getOrCreateLink(Rank, ranking._node, entity._node, Constants.REL_RANK, {
              rank: rank + 1,
              rankingName: ranking.serialize().name
            }, __iced_deferrals.defer({
              assign_fn: (function(__slot_1, __slot_2, __slot_3, __slot_4) {
                return function() {
                  __slot_1[__slot_2] = arguments[0];
                  return __slot_3[__slot_4] = arguments[1];
                };
              })(errs, rank, rankLinks, rank),
              lineno: 96
            }));
          }
          __iced_deferrals._fulfill();
        })(function() {
          shareToken = SchemaUtil.Security.hashids.encrypt(ranking._node.id);
          ranking._node.data.shareToken = shareToken;
          publicUser = null;
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "ranking.coffee",
              funcname: "_create"
            });
            if (!ranking._node.data["private"]) {
              User.get("public", __iced_deferrals.defer({
                assign_fn: (function() {
                  return function() {
                    err = arguments[0];
                    return publicUser = arguments[1];
                  };
                })(),
                lineno: 104
              }));
            }
            redis.set("ranking:" + ranking._node.id + ":shareToken", shareToken, __iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  err = arguments[0];
                  return ok = arguments[1];
                };
              })(),
              lineno: 108
            }));
            ranking.save(__iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  return err = arguments[0];
                };
              })(),
              lineno: 109
            }));
            __iced_deferrals._fulfill();
          })(function() {
            if (publicUser) {
              console.log("LINKING TO PUBLIC USER");
              CypherLinkUtil.createLink(publicUser._node, ranking._node, Constants.REL_RANKING, {}, function(err, rel) {});
            }
            return Response.OKResponse(res)(201, ranking.serialize(null, {
              shareToken: shareToken
            }));
          });
        });
      });
    });
  };

  exports.create = basicAuthentication(_create);

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
        lineno: 122
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue());
      }
      return Response.OKResponse(res)(200, ranking.serialize());
    });
  };

  _showDetail = function(req, res, next) {
    var attrBlobs, entity, entityId, err, ind, rankedEntities, ranking, sRankedEntities, sRanking, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "ranking.coffee",
        funcname: "_showDetail"
      });
      Ranking.get(req.params.rankingId, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return ranking = arguments[1];
          };
        })(),
        lineno: 128
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue());
      }
      rankedEntities = [];
      attrBlobs = [];
      sRankedEntities = [];
      sRanking = ranking.serialize();
      (function(__iced_k) {
        var _i, _len, _ref;
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "ranking.coffee",
          funcname: "_showDetail"
        });
        _ref = sRanking.ranks;
        for (ind = _i = 0, _len = _ref.length; _i < _len; ind = ++_i) {
          entityId = _ref[ind];
          Entity.get(entityId, __iced_deferrals.defer({
            assign_fn: (function(__slot_1, __slot_2) {
              return function() {
                err = arguments[0];
                return __slot_1[__slot_2] = arguments[1];
              };
            })(rankedEntities, ind),
            lineno: 138
          }));
        }
        __iced_deferrals._fulfill();
      })(function() {
        (function(__iced_k) {
          var _i, _len;
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "ranking.coffee",
            funcname: "_showDetail"
          });
          for (ind = _i = 0, _len = rankedEntities.length; _i < _len; ind = ++_i) {
            entity = rankedEntities[ind];
            EntityUtil.getEntityAttributes(entity, __iced_deferrals.defer({
              assign_fn: (function(__slot_1, __slot_2) {
                return function() {
                  return __slot_1[__slot_2] = arguments[0];
                };
              })(attrBlobs, ind),
              lineno: 142
            }));
          }
          __iced_deferrals._fulfill();
        })(function() {
          var _i, _len;
          for (ind = _i = 0, _len = rankedEntities.length; _i < _len; ind = ++_i) {
            entity = rankedEntities[ind];
            sRankedEntities[ind] = entity.serialize(null, {
              attributes: attrBlobs[ind]
            });
          }
          return Response.OKResponse(res)(200, sRankedEntities);
        });
      });
    });
  };

  exports.show = basicAuthentication(_show);

  _edit = function(req, res, next) {
    var entities, entity, entityId, err, errR, errs, ind, newRankIds, newRanking, oldRanking, rankMap, ranking, rel, rels, removedRankIds, updateRankIds, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    if (!req.body.name || !req.body.ranks) {
      return Response.ErrorResponse(res)(400, ErrorDevMessage.missingParam("name or rank"));
    }
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "ranking.coffee",
        funcname: "_edit"
      });
      Ranking.get(req.params.rankingId, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errR = arguments[0];
            return ranking = arguments[1];
          };
        })(),
        lineno: 158
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (errR) {
        return Response.ErrorResponse(res)(400, errR);
      }
      oldRanking = _und.clone(ranking.serialize());
      req.body.createdBy = req.user._node.data.username;
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "ranking.coffee",
          funcname: "_edit"
        });
        Ranking.put(req.params.rankingId, req.body, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              errR = arguments[0];
              return ranking = arguments[1];
            };
          })(),
          lineno: 164
        }));
        __iced_deferrals._fulfill();
      })(function() {
        var _i, _ref, _results;
        if (errR) {
          return Response.ErrorResponse(res)(400, errR);
        }
        newRanking = _und.clone(ranking.serialize());
        console.log("Old Ranking");
        console.log(oldRanking);
        console.log("New Ranking");
        console.log(newRanking);
        rankMap = _und.object(newRanking.ranks, (function() {
          _results = [];
          for (var _i = 1, _ref = newRanking.ranks.length; 1 <= _ref ? _i <= _ref : _i >= _ref; 1 <= _ref ? _i++ : _i--){ _results.push(_i); }
          return _results;
        }).apply(this));
        console.log("RankMap");
        console.log(rankMap);
        removedRankIds = _und.difference(oldRanking.ranks, newRanking.ranks);
        console.log("To Remove");
        console.log(removedRankIds);
        entities = [];
        (function(__iced_k) {
          var _j, _len;
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "ranking.coffee",
            funcname: "_edit"
          });
          for (ind = _j = 0, _len = removedRankIds.length; _j < _len; ind = ++_j) {
            entityId = removedRankIds[ind];
            Entity.get(entityId, __iced_deferrals.defer({
              assign_fn: (function(__slot_1, __slot_2) {
                return function() {
                  err = arguments[0];
                  return __slot_1[__slot_2] = arguments[1];
                };
              })(entities, ind),
              lineno: 190
            }));
          }
          __iced_deferrals._fulfill();
        })(function() {
          (function(__iced_k) {
            var _j, _len;
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "ranking.coffee",
              funcname: "_edit"
            });
            for (ind = _j = 0, _len = entities.length; _j < _len; ind = ++_j) {
              entity = entities[ind];
              CypherLinkUtil.deleteLink(Rank, ranking._node, entity._node, Constants.REL_RANK);
            }
            __iced_deferrals._fulfill();
          })(function() {
            newRankIds = _und.difference(newRanking.ranks, oldRanking.ranks);
            console.log("To Add");
            console.log(newRankIds);
            entities = [];
            (function(__iced_k) {
              var _j, _len;
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                filename: "ranking.coffee",
                funcname: "_edit"
              });
              for (ind = _j = 0, _len = newRankIds.length; _j < _len; ind = ++_j) {
                entityId = newRankIds[ind];
                Entity.get(entityId, __iced_deferrals.defer({
                  assign_fn: (function(__slot_1, __slot_2) {
                    return function() {
                      err = arguments[0];
                      return __slot_1[__slot_2] = arguments[1];
                    };
                  })(entities, ind),
                  lineno: 205
                }));
              }
              __iced_deferrals._fulfill();
            })(function() {
              (function(__iced_k) {
                var _j, _len;
                __iced_deferrals = new iced.Deferrals(__iced_k, {
                  parent: ___iced_passed_deferral,
                  filename: "ranking.coffee",
                  funcname: "_edit"
                });
                for (ind = _j = 0, _len = entities.length; _j < _len; ind = ++_j) {
                  entity = entities[ind];
                  CypherLinkUtil.getOrCreateLink(Rank, ranking._node, entity._node, Constants.REL_RANK, {
                    rank: rankMap[entity._node.id.toString()],
                    rankingName: newRanking.name
                  }, function(err, rel) {});
                }
                __iced_deferrals._fulfill();
              })(function() {
                updateRankIds = _und.intersection(newRanking.ranks, oldRanking.ranks);
                console.log("To Update");
                console.log(updateRankIds);
                entities = [];
                (function(__iced_k) {
                  var _j, _len;
                  __iced_deferrals = new iced.Deferrals(__iced_k, {
                    parent: ___iced_passed_deferral,
                    filename: "ranking.coffee",
                    funcname: "_edit"
                  });
                  for (ind = _j = 0, _len = updateRankIds.length; _j < _len; ind = ++_j) {
                    entityId = updateRankIds[ind];
                    Entity.get(entityId, __iced_deferrals.defer({
                      assign_fn: (function(__slot_1, __slot_2) {
                        return function() {
                          err = arguments[0];
                          return __slot_1[__slot_2] = arguments[1];
                        };
                      })(entities, ind),
                      lineno: 222
                    }));
                  }
                  __iced_deferrals._fulfill();
                })(function() {
                  errs = [];
                  rels = [];
                  (function(__iced_k) {
                    var _j, _len;
                    __iced_deferrals = new iced.Deferrals(__iced_k, {
                      parent: ___iced_passed_deferral,
                      filename: "ranking.coffee",
                      funcname: "_edit"
                    });
                    for (ind = _j = 0, _len = entities.length; _j < _len; ind = ++_j) {
                      entity = entities[ind];
                      console.log("for entity " + entity._node.id + "@" + rankMap[entity._node.id.toString()]);
                      CypherLinkUtil.updateLink(Rank, ranking._node, entity._node, Constants.REL_RANK, {
                        rank: rankMap[entity._node.id.toString()],
                        rankingName: newRanking.name
                      }, __iced_deferrals.defer({
                        assign_fn: (function() {
                          return function() {
                            err = arguments[0];
                            return rel = arguments[1];
                          };
                        })(),
                        lineno: 234
                      }));
                    }
                    __iced_deferrals._fulfill();
                  })(function() {
                    err = _und.find(errs, function(err) {
                      return err;
                    });
                    if (err) {
                      return cb(true, ErrorResponse(500, ErrorDevMessage.dbIssue()), null);
                    }
                    return Response.OKResponse(res)(200, {});
                  });
                });
              });
            });
          });
        });
      });
    });
  };

  exports.edit = basicAuthentication(_edit);

  _delete = function(req, res, next) {
    return res.status(503).json({
      error: "Not Implemented"
    });
  };

  exports["delete"] = basicAuthentication(_delete);

  exports.shareView = function(req, res, next) {
    var rankingId;
    rankingId = SchemaUtil.Security.hashids.decrypt(req.params.shareToken);
    if (parseInt(rankingId)) {
      req.params.rankingId = rankingId;
      return _showDetail(req, res, next);
    } else {
      return res.status(404).json({
        error: "Not Found"
      });
    }
  };

}).call(this);

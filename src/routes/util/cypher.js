// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var CypherLinkUtil, CypherQueryBuilder, Logger, iced, __iced_k, __iced_k_noop, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  Logger = require('../../util/logger');

  CypherQueryBuilder = (function() {
    var instance, _CypherQueryBuilder;

    function CypherQueryBuilder() {}

    instance = null;

    _CypherQueryBuilder = (function() {
      function _CypherQueryBuilder() {}

      _CypherQueryBuilder.prototype.getOutgoingRelsCypherQuery = function(startId, relType) {
        var cypher;
        cypher = "START n=node(" + startId + ") MATCH n-[r]->other ";
        if (relType === "relation") {
          cypher += "WHERE type(r) <> " + Constants.REL_VOTED + " ";
        } else {
          cypher += "WHERE type(r) = '" + (Link.normalizeName(relType)) + "'";
        }
        return cypher += " RETURN r;";
      };

      return _CypherQueryBuilder;

    })();

    CypherQueryBuilder.get = function() {
      return instance != null ? instance : instance = new _CypherQueryBuilder();
    };

    return CypherQueryBuilder;

  })();

  CypherLinkUtil = (function() {
    function CypherLinkUtil() {}

    CypherLinkUtil.getRelationId = function(path) {
      var splits;
      splits = path.relationships[0]._data.self.split('/');
      return splits[splits.length - 1];
    };

    CypherLinkUtil.hasLink = function(startNode, otherNode, linkType, dir, cb) {
      if (dir == null) {
        dir = "all";
      }
      return startNode.path(otherNode, linkType, dir, 1, 'shortestPath', function(err, path) {
        Logger.debugging("Cypher hasLink finished");
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

    CypherLinkUtil.createLink = function(startNode, otherNode, linkType, linkData, cb) {
      Logger.debug("Creating linkType: " + linkType);
      Logger.debug("StartingNode: " + startNode.id);
      Logger.debug("OtherNode: " + otherNode.id);
      Logger.debug("LinkType: " + linkType);
      return startNode.createRelationshipTo(otherNode, linkType, linkData, function(err, link) {
        if (err) {
          Logger.debug("Finished with err: " + err);
          return cb(new Error("Unable to create link"), null);
        } else {
          return cb(null, link);
        }
      });
    };

    CypherLinkUtil.getOrCreateLink = function(Class, startNode, otherNode, linkType, linkData, cb) {
      var err, path, relId, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "routes/util/cypher.coffee",
          funcname: "CypherLinkUtil.getOrCreateLink"
        });
        _this.hasLink(startNode, otherNode, linkType, "out", __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return path = arguments[1];
            };
          })(),
          lineno: 60
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (!path) {
          return _this.createLink(startNode, otherNode, linkType, linkData, cb);
        } else {
          relId = _this.getRelationId(path);
          return Class.get(relId, cb);
        }
      });
    };

    CypherLinkUtil.updateLink = function(Class, startNode, otherNode, linkType, linkData, cb) {
      var err, path, relId, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "routes/util/cypher.coffee",
          funcname: "CypherLinkUtil.updateLink"
        });
        _this.hasLink(startNode, otherNode, linkType, "all", __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return path = arguments[1];
            };
          })(),
          lineno: 78
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          Logger.error("UpdateLink ERR " + err);
          return cb("Unable to retrieve link", null);
        } else if (!path) {
          Logger.debug("UpdateLink Didn't find path");
          return cb("Link does not exist", null);
        }
        relId = _this.getRelationId(path);
        return Class.put(relId, linkData, cb);
      });
    };

    CypherLinkUtil.deleteLink = function(Class, startNode, otherNode, linkType, cb) {
      var err, link, path, relId, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "routes/util/cypher.coffee",
          funcname: "CypherLinkUtil.deleteLink"
        });
        _this.hasLink(startNode, otherNode, linkType, "out", __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return path = arguments[1];
            };
          })(),
          lineno: 95
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (!path) {
          return cb(null, null);
        } else if (err) {
          return cb("Unable to retrieve link", null);
        }
        relId = _this.getRelationId(path);
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "routes/util/cypher.coffee",
            funcname: "CypherLinkUtil.deleteLink"
          });
          Class.get(relId, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                err = arguments[0];
                return link = arguments[1];
              };
            })(),
            lineno: 105
          }));
          __iced_deferrals._fulfill();
        })(function() {
          return link.del();
        });
      });
    };

    CypherLinkUtil.createMultipleLinks = function(startNode, otherNode, links, linkData, cb) {
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
          filename: "routes/util/cypher.coffee",
          funcname: "CypherLinkUtil.createMultipleLinks"
        });
        for (ind = _i = 0, _len = links.length; _i < _len; ind = ++_i) {
          link = links[ind];
          _this.createLink(startNode, otherNode, link, linkData, __iced_deferrals.defer({
            assign_fn: (function(__slot_1, __slot_2, __slot_3, __slot_4) {
              return function() {
                __slot_1[__slot_2] = arguments[0];
                return __slot_3[__slot_4] = arguments[1];
              };
            })(errs, ind, rels, ind),
            lineno: 119
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

    return CypherLinkUtil;

  })();

  exports.CypherQueryBuilder = CypherQueryBuilder.get();

  exports.CypherLinkUtil = CypherLinkUtil;

}).call(this);

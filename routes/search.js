// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Attribute, Constants, Entity, Neo, OTHER_SPLIT_REGEX, REL_SPLIT_REGEX, Ranking, SchemaUtil, Tag, Utility, Vote, cypherQueryConstructor, iced, luceneQueryContructor, queryAnalyzer, searchFunc, searchableClass, trim, __iced_k, __iced_k_noop, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  require('source-map-support').install();

  _und = require('underscore');

  trim = require('../misc/stringUtil').trim;

  Neo = require('../models/neo');

  Entity = require('../models/entity');

  Ranking = require('../models/ranking');

  Vote = require('../models/vote');

  Attribute = require('../models/attribute');

  Tag = require('../models/tag');

  SchemaUtil = require('../models/stdSchema');

  Constants = SchemaUtil.Constants;

  Utility = require('./utility');

  OTHER_SPLIT_REGEX = /\bwith\b/;

  REL_SPLIT_REGEX = /\bvia\b/;

  searchableClass = {
    entity: Entity,
    attribute: Attribute,
    tag: Tag
  };

  searchFunc = {
    cypher: Neo.query,
    lucene: Neo.search
  };

  queryAnalyzer = function(searchClass, query) {
    var mainQuery, otherQuery, relQuery, remainder, _ref, _ref1;
    mainQuery = otherQuery = relQuery = '';
    console.log("query: " + query);
    _ref = query.split(OTHER_SPLIT_REGEX), mainQuery = _ref[0], remainder = _ref[1];
    console.log("mainQuery: " + mainQuery);
    if (remainder) {
      _ref1 = remainder.split(REL_SPLIT_REGEX), otherQuery = _ref1[0], remainder = _ref1[1];
    }
    console.log("otherQuery: " + otherQuery);
    console.log("relQuery: " + remainder);
    if (!!mainQuery) {
      mainQuery = encodeURIComponent(_und.escape(mainQuery.trim()));
    }
    if (!!otherQuery) {
      otherQuery = otherQuery.split(',').map(function(item) {
        return encodeURIComponent(_und.escape(item.trim()));
      }).filter(function(item) {
        if (!!item) {
          return item;
        }
      });
    }
    if (!!remainder) {
      relQuery = remainder.split(',').map(function(item) {
        return encodeURIComponent(_und.escape(item.trim()));
      }).filter(function(item) {
        if (!!item) {
          return item;
        }
      });
    }
    return cypherQueryConstructor(searchClass, mainQuery, otherQuery, relQuery);
  };

  cypherQueryConstructor = function(searchClass, name, otherMatches, relMatches) {
    var endQ, ind, otherMatchQ, otherName, relationship, startNodeQ, _i, _len;
    if (name == null) {
      name = '';
    }
    if (otherMatches == null) {
      otherMatches = [];
    }
    if (relMatches == null) {
      relMatches = [];
    }
    console.log("name: " + name);
    console.log("otherMatches: " + otherMatches);
    console.log("relationMatches: " + relMatches);
    startNodeQ = "START n=node:__indexName__('name:" + name + "~0.65')";
    endQ = 'RETURN DISTINCT n AS result;';
    otherMatchQ = [];
    for (ind = _i = 0, _len = otherMatches.length; _i < _len; ind = ++_i) {
      otherName = otherMatches[ind];
      if (ind < relMatches.length) {
        relationship = relMatches[ind];
      } else {
        relationship = Constants.REL_ATTRIBUTE;
      }
      otherMatchQ.push("MATCH (n)<-[:" + relationship + "]-(other) WHERE other.name=~'(?i)" + (decodeURIComponent(otherName)) + "'");
    }
    otherMatchQ = otherMatchQ.join(' WITH n as n ');
    switch (searchClass) {
      case Tag:
        return [startNodeQ, "MATCH (n)-[:_TAG]->(entity) WITH entity as n", otherMatchQ, "WITH n as n", endQ].join('\n');
      case Attribute:
        return [startNodeQ, "MATCH (n)-[:_ATTRIBUTE]->(entity) WITH entity as n", otherMatchQ, "WITH n as n", endQ].join('\n');
      default:
        return [startNodeQ, otherMatchQ, "WITH n as n", endQ].join('\n');
    }
  };

  luceneQueryContructor = function(query) {
    var key, queryString, val, _i, _len;
    queryString = [];
    for (val = _i = 0, _len = query.length; _i < _len; val = ++_i) {
      key = query[val];
      queryString.push("" + key + ":" + val);
    }
    return queryString.join("AND");
  };

  exports.searchHandler = function(req, res, next) {
    var attrBlobs, authorized, blobResults, cQuery, cleanedQuery, entity, entitySerialized, err, errU, errs, identified, ind, indX, indY, item, obj, query, rankingName, rankingQuery, rankingResult, result, resultBlob, results, sRanking, searchClass, searchClasses, user, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    if (!req.query['q']) {
      return res.json({});
    }
    cleanedQuery = trim(req.query.q);
    if (req.params.type) {
      searchClasses = [searchableClass[req.params.type]];
    } else {
      searchClasses = _und.values(searchableClass);
    }
    results = [];
    errs = [];
    rankingQuery = cleanedQuery.indexOf("ranking:") >= 0;
    (function(__iced_k) {
      var _i, _len;
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "search.coffee",
        funcname: "searchHandler"
      });
      Utility.getUser(req, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errU = arguments[0];
            return user = arguments[1];
          };
        })(),
        lineno: 112
      }));
      if (rankingQuery) {
        rankingName = encodeURIComponent(_und.escape(cleanedQuery.substr(8).trim()));
        cQuery = "START n=node:nRanking('name:" + rankingName + "~0.25') MATCH (n)-[r:_RANK]->(x)                RETURN DISTINCT n AS ranking, r.rank AS rank, x AS entity ORDER BY ID(n), r.rank;";
        Neo.query(Ranking, cQuery, {}, __iced_deferrals.defer({
          assign_fn: (function(__slot_1, __slot_2) {
            return function() {
              __slot_1[__slot_2] = arguments[0];
              return rankingResult = arguments[1];
            };
          })(errs, ind),
          lineno: 122
        }));
      } else {
        for (ind = _i = 0, _len = searchClasses.length; _i < _len; ind = ++_i) {
          searchClass = searchClasses[ind];
          query = queryAnalyzer(searchClass, cleanedQuery);
          console.log(query);
          Neo.query(searchClass, query.replace('__indexName__', searchClass.INDEX_NAME), {}, __iced_deferrals.defer({
            assign_fn: (function(__slot_1, __slot_2, __slot_3, __slot_4) {
              return function() {
                __slot_1[__slot_2] = arguments[0];
                return __slot_3[__slot_4] = arguments[1];
              };
            })(errs, ind, results, ind),
            lineno: 132
          }));
        }
      }
      __iced_deferrals._fulfill();
    })(function() {
      err = _und.find(errs, function(err) {
        return err;
      });
      if (err || errU) {
        return res.status(500).json({
          error: "Unable to execute query. Please try again later"
        });
      }
      resultBlob = [];
      identified = {};
      (function(__iced_k) {
        if (rankingQuery) {
          (function(__iced_k) {
            var _i, _len, _ref, _results, _while;
            _ref = rankingResult;
            _len = _ref.length;
            ind = 0;
            _results = [];
            _while = function(__iced_k) {
              var _break, _continue, _next;
              _break = function() {
                return __iced_k(_results);
              };
              _continue = function() {
                return iced.trampoline(function() {
                  ++ind;
                  return _while(__iced_k);
                });
              };
              _next = function(__iced_next_arg) {
                _results.push(__iced_next_arg);
                return _continue();
              };
              if (!(ind < _len)) {
                return _break();
              } else {
                item = _ref[ind];
                sRanking = (new Ranking(item.ranking)).serialize();
                if (!identified[sRanking.id]) {
                  sRanking.entities = identified[sRanking.id] = [];
                  resultBlob.push(sRanking);
                }
                entity = new Entity(item.entity);
                (function(__iced_k) {
                  __iced_deferrals = new iced.Deferrals(__iced_k, {
                    parent: ___iced_passed_deferral,
                    filename: "search.coffee",
                    funcname: "searchHandler"
                  });
                  Utility.hasPermission(user, entity, __iced_deferrals.defer({
                    assign_fn: (function() {
                      return function() {
                        err = arguments[0];
                        return authorized = arguments[1];
                      };
                    })(),
                    lineno: 152
                  }));
                  __iced_deferrals._fulfill();
                })(function() {
                  (function(__iced_k) {
                    if (!authorized) {
                      (function(__iced_k) {
_continue()
                      })(__iced_k);
                    } else {
                      return __iced_k();
                    }
                  })(function() {
                    (function(__iced_k) {
                      __iced_deferrals = new iced.Deferrals(__iced_k, {
                        parent: ___iced_passed_deferral,
                        filename: "search.coffee",
                        funcname: "searchHandler"
                      });
                      Utility.getEntityAttributes(entity, __iced_deferrals.defer({
                        assign_fn: (function() {
                          return function() {
                            return attrBlobs = arguments[0];
                          };
                        })(),
                        lineno: 157
                      }));
                      __iced_deferrals._fulfill();
                    })(function() {
                      entitySerialized = entity.serialize(null, {
                        attributes: attrBlobs
                      });
                      return _next(identified[sRanking.id].push(entitySerialized));
                    });
                  });
                });
              }
            };
            _while(__iced_k);
          })(function() {
            return res.json(resultBlob);
            return __iced_k();
          });
        } else {
          return __iced_k();
        }
      })(function() {
        blobResults = [];
        (function(__iced_k) {
          var _i, _len, _ref, _results, _while;
          _ref = results;
          _len = _ref.length;
          indX = 0;
          _results = [];
          _while = function(__iced_k) {
            var _break, _continue, _next;
            _break = function() {
              return __iced_k(_results);
            };
            _continue = function() {
              return iced.trampoline(function() {
                ++indX;
                return _while(__iced_k);
              });
            };
            _next = function(__iced_next_arg) {
              _results.push(__iced_next_arg);
              return _continue();
            };
            if (!(indX < _len)) {
              return _break();
            } else {
              result = _ref[indX];
              (function(__iced_k) {
                var _j, _len1, _ref1, _results1, _while;
                _ref1 = result;
                _len1 = _ref1.length;
                indY = 0;
                _results1 = [];
                _while = function(__iced_k) {
                  var _break, _continue, _next;
                  _break = function() {
                    return __iced_k(_results1);
                  };
                  _continue = function() {
                    return iced.trampoline(function() {
                      ++indY;
                      return _while(__iced_k);
                    });
                  };
                  _next = function(__iced_next_arg) {
                    _results1.push(__iced_next_arg);
                    return _continue();
                  };
                  if (!(indY < _len1)) {
                    return _break();
                  } else {
                    obj = _ref1[indY];
                    entity = new Entity(obj.result);
                    (function(__iced_k) {
                      __iced_deferrals = new iced.Deferrals(__iced_k, {
                        parent: ___iced_passed_deferral,
                        filename: "search.coffee",
                        funcname: "searchHandler"
                      });
                      Utility.hasPermission(user, entity, __iced_deferrals.defer({
                        assign_fn: (function() {
                          return function() {
                            err = arguments[0];
                            return authorized = arguments[1];
                          };
                        })(),
                        lineno: 169
                      }));
                      __iced_deferrals._fulfill();
                    })(function() {
                      (function(__iced_k) {
                        if (!authorized) {
                          (function(__iced_k) {
_continue()
                          })(__iced_k);
                        } else {
                          return __iced_k();
                        }
                      })(function() {
                        (function(__iced_k) {
                          __iced_deferrals = new iced.Deferrals(__iced_k, {
                            parent: ___iced_passed_deferral,
                            filename: "search.coffee",
                            funcname: "searchHandler"
                          });
                          Utility.getEntityAttributes(entity, __iced_deferrals.defer({
                            assign_fn: (function() {
                              return function() {
                                return attrBlobs = arguments[0];
                              };
                            })(),
                            lineno: 172
                          }));
                          __iced_deferrals._fulfill();
                        })(function() {
                          entitySerialized = entity.serialize(null, {
                            attributes: attrBlobs
                          });
                          return _next(!identified[entitySerialized.id] ? (blobResults.push(entitySerialized), identified[entitySerialized.id] = true) : void 0);
                        });
                      });
                    });
                  }
                };
                _while(__iced_k);
              })(_next);
            }
          };
          _while(__iced_k);
        })(function() {
          return res.json(blobResults);
        });
      });
    });
  };

}).call(this);

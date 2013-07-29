// Generated by IcedCoffeeScript 1.6.2d
(function() {
  var Attribute, Constants, Entity, Link, Neo, Response, StdSchema, Tag, Utility, Vote, getOutgoingRelsCypherQuery, iced, __iced_k, __iced_k_noop, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  Neo = require('../models/neo');

  Entity = require('../models/entity');

  Attribute = require('../models/attribute');

  Tag = require('../models/tag');

  Vote = require('../models/vote');

  Link = require('../models/link');

  StdSchema = require('../models/stdSchema');

  Constants = StdSchema.Constants;

  Response = StdSchema;

  Utility = require('./utility');

  getOutgoingRelsCypherQuery = function(startId, relType) {
    var cypher;
    cypher = "START n=node(" + startId + ") MATCH n-[r]->other ";
    if (relType === "relation") {
      cypher += "WHERE type(r) <> '_VOTE'";
    } else {
      cypher += "WHERE type(r) = '" + (Link.normalizeName(relType)) + "'";
    }
    return cypher += " RETURN r;";
  };

  exports.search = function(req, res, next) {
    return res.redirect("/search/?q=" + req.query['q']);
  };

  exports.create = function(req, res, next) {
    var blob, entity, err, errs, ind, tagName, tagObj, tagObjs, tags, ___iced_passed_deferral, __iced_deferrals, __iced_k, _ref,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    errs = [];
    tagObjs = [];
    tags = (_ref = req.body['tags']) != null ? _ref : [];
    (function(__iced_k) {
      var _i, _len;
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "entity.coffee",
        funcname: "create"
      });
      for (ind = _i = 0, _len = tags.length; _i < _len; ind = ++_i) {
        tagName = tags[ind];
        Tag.getOrCreate(tagName, __iced_deferrals.defer({
          assign_fn: (function(__slot_1, __slot_2, __slot_3, __slot_4) {
            return function() {
              __slot_1[__slot_2] = arguments[0];
              return __slot_3[__slot_4] = arguments[1];
            };
          })(errs, ind, tagObjs, ind),
          lineno: 44
        }));
      }
      __iced_deferrals._fulfill();
    })(function() {
      err = _und.find(errs, function(err) {
        return err;
      });
      if (err) {
        return next(err);
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "entity.coffee",
          funcname: "create"
        });
        Entity.create(req.body, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return entity = arguments[1];
            };
          })(),
          lineno: 49
        }));
        __iced_deferrals._fulfill();
      })(function() {
        var _i, _len;
        if (err) {
          return next(err);
        }
        for (ind = _i = 0, _len = tagObjs.length; _i < _len; ind = ++_i) {
          tagObj = tagObjs[ind];
          tagObj._node.createRelationshipTo(entity._node, Constants.REL_TAG, {}, function(err, rel) {});
        }
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "entity.coffee",
            funcname: "create"
          });
          entity.serialize(__iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                return blob = arguments[0];
              };
            })(),
            lineno: 58
          }));
          __iced_deferrals._fulfill();
        })(function() {
          return res.status(201).json(blob);
        });
      });
    });
  };

  exports.show = function(req, res, next) {
    var attrBlobs, entity, entityBlob, err, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    if (isNaN(req.params.id)) {
      return res.json({});
    }
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "entity.coffee",
        funcname: "show"
      });
      Entity.get(req.params.id, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return entity = arguments[1];
          };
        })(),
        lineno: 67
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return next(err);
      }
      (function(__iced_k) {
        if (req.query['attr'] !== "false") {
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "entity.coffee",
              funcname: "show"
            });
            Utility.getEntityAttributes(entity, __iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  return attrBlobs = arguments[0];
                };
              })(),
              lineno: 73
            }));
            __iced_deferrals._fulfill();
          })(function() {
            return __iced_k(entityBlob = entity.serialize(null, {
              attributes: attrBlobs
            }));
          });
        } else {
          return __iced_k(entityBlob = entity.serialize(null, entityBlob));
        }
      })(function() {
        return res.json(entityBlob);
      });
    });
  };

  exports.edit = function(req, res, next) {
    var blob, entity, err, errs, ind, tagName, tagObj, tagObjs, tags, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "entity.coffee",
        funcname: "edit"
      });
      Entity.put(req.params.id, req.body, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return entity = arguments[1];
          };
        })(),
        lineno: 82
      }));
      __iced_deferrals._fulfill();
    })(function() {
      var _ref;
      if (err) {
        return next(err);
      }
      errs = [];
      tagObjs = [];
      tags = (_ref = req.body['tags']) != null ? _ref : [];
      (function(__iced_k) {
        var _i, _len;
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "entity.coffee",
          funcname: "edit"
        });
        for (ind = _i = 0, _len = tags.length; _i < _len; ind = ++_i) {
          tagName = tags[ind];
          Tag.getOrCreate(tagName, __iced_deferrals.defer({
            assign_fn: (function(__slot_1, __slot_2, __slot_3, __slot_4) {
              return function() {
                __slot_1[__slot_2] = arguments[0];
                return __slot_3[__slot_4] = arguments[1];
              };
            })(errs, ind, tagObjs, ind),
            lineno: 92
          }));
        }
        __iced_deferrals._fulfill();
      })(function() {
        var _i, _len;
        err = _und.find(errs, function(err) {
          return err;
        });
        if (err) {
          return next(err);
        }
        for (ind = _i = 0, _len = tagObjs.length; _i < _len; ind = ++_i) {
          tagObj = tagObjs[ind];
          tagObj._node.createRelationshipTo(entity._node, Constants.REL_TAG, {}, function(err, rel) {});
        }
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "entity.coffee",
            funcname: "edit"
          });
          entity.serialize(__iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                return blob = arguments[0];
              };
            })(),
            lineno: 103
          }));
          __iced_deferrals._fulfill();
        })(function() {
          return res.json(blob);
        });
      });
    });
  };

  exports.del = function(req, res, next) {
    var entity, err, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "entity.coffee",
        funcname: "del"
      });
      Entity.get(req.params.id, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return entity = arguments[1];
          };
        })(),
        lineno: 108
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return next(err);
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "entity.coffee",
          funcname: "del"
        });
        entity.del(__iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              return err = arguments[0];
            };
          })(),
          lineno: 111
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          return next(err);
        }
        return res.status(204).send();
      });
    });
  };

  exports.listAttribute = function(req, res, next) {
    var blob, blobs, entity, err, errE, ind, linkData, node, nodes, rels, startendVal, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "entity.coffee",
        funcname: "listAttribute"
      });
      Entity.get(req.params.id, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errE = arguments[0];
            return entity = arguments[1];
          };
        })(),
        lineno: 119
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return next(err);
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "entity.coffee",
          funcname: "listAttribute"
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
          lineno: 124
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          return next(err);
        }
        rels = [];
        blobs = [];
        (function(__iced_k) {
          var _i, _len;
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "entity.coffee",
            funcname: "listAttribute"
          });
          for (ind = _i = 0, _len = nodes.length; _i < _len; ind = ++_i) {
            node = nodes[ind];
            startendVal = Utility.getStartEndIndex(node.id, Constants.REL_ATTRIBUTE, req.params.id);
            Link.find('startend', startendVal, __iced_deferrals.defer({
              assign_fn: (function(__slot_1, __slot_2) {
                return function() {
                  err = arguments[0];
                  return __slot_1[__slot_2] = arguments[1];
                };
              })(rels, ind),
              lineno: 138
            }));
            (new Attribute(node)).serialize(__iced_deferrals.defer({
              assign_fn: (function(__slot_1, __slot_2) {
                return function() {
                  return __slot_1[__slot_2] = arguments[0];
                };
              })(blobs, ind),
              lineno: 139
            }), entity._node.id);
          }
          __iced_deferrals._fulfill();
        })(function() {
          var _i, _len;
          for (ind = _i = 0, _len = blobs.length; _i < _len; ind = ++_i) {
            blob = blobs[ind];
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
          return res.json(blobs);
        });
      });
    });
  };

  exports.addAttribute = function(req, res, next) {
    var attr, blob, data, entity, err, errA, errE, linkData, rel, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    data = _und.clone(req.body);
    delete data['id'];
    console.log(data);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "entity.coffee",
        funcname: "addAttribute"
      });
      Entity.get(req.params.id, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errE = arguments[0];
            return entity = arguments[1];
          };
        })(),
        lineno: 159
      }));
      Attribute.getOrCreate(data, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errA = arguments[0];
            return attr = arguments[1];
          };
        })(),
        lineno: 160
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (errE) {
        return next(errE);
      }
      if (errA) {
        return next(errA);
      }
      linkData = Link.normalizeData(_und.clone(req.body['linkData'] || {}));
      linkData['startend'] = Utility.getStartEndIndex(attr._node.id, Constants.REL_ATTRIBUTE, req.params.id);
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "entity.coffee",
          funcname: "addAttribute"
        });
        attr._node.createRelationshipTo(entity._node, Constants.REL_ATTRIBUTE, linkData, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return rel = arguments[1];
            };
          })(),
          lineno: 175
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          return next(err);
        }
        Link.index(rel, linkData);
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "entity.coffee",
            funcname: "addAttribute"
          });
          attr.serialize(__iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                return blob = arguments[0];
              };
            })(),
            lineno: 180
          }));
          __iced_deferrals._fulfill();
        })(function() {
          _und.extend(blob, {
            linkData: linkData
          });
          return res.status(201).json(blob);
        });
      });
    });
  };

  exports.delAttribute = function(req, res, next) {
    var attr, entity, errA, errE, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "entity.coffee",
        funcname: "delAttribute"
      });
      Entity.get(req.params.eId, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errE = arguments[0];
            return entity = arguments[1];
          };
        })(),
        lineno: 187
      }));
      __iced_deferrals._fulfill();
    })(function() {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "entity.coffee",
        funcname: "delAttribute"
      });
      Attribute.get(req.params.aId, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errA = arguments[0];
            return attr = arguments[1];
          };
        })(),
        lineno: 188
      }));
      __iced_deferrals._fulfill();
    });
  };

  exports.getAttribute = function(req, res, next) {
    var attr, attrId, blob, entityId, err, errAttr, errLink, rel, startendVal, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    attrId = req.params.aId;
    entityId = req.params.eId;
    startendVal = Utility.getStartEndIndex(attrId, Constants.REL_ATTRIBUTE, entityId);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "entity.coffee",
        funcname: "getAttribute"
      });
      Link.find('startend', startendVal, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errLink = arguments[0];
            return rel = arguments[1];
          };
        })(),
        lineno: 201
      }));
      Attribute.get(attrId, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errAttr = arguments[0];
            return attr = arguments[1];
          };
        })(),
        lineno: 202
      }));
      __iced_deferrals._fulfill();
    })(function() {
      err = errLink || errAttr;
      if (err) {
        return next(err);
      }
      blob = {};
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "entity.coffee",
          funcname: "getAttribute"
        });
        attr.serialize(__iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              return blob = arguments[0];
            };
          })(),
          lineno: 208
        }), entityId);
        __iced_deferrals._fulfill();
      })(function() {
        _und.extend(blob, {
          linkData: rel.serialize()
        });
        return res.json(blob);
      });
    });
  };

  exports.updateAttributeLink = function(req, res, next) {
    var attr, attrId, blob, entityId, err, errAttr, errLink, linkData, rel, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    attrId = req.params.aId;
    entityId = req.params.eId;
    linkData = _und.clone(req.body['linkData'] || {});
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "entity.coffee",
        funcname: "updateAttributeLink"
      });
      Attribute.get(attrId, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errAttr = arguments[0];
            return attr = arguments[1];
          };
        })(),
        lineno: 222
      }));
      Link.put(linkData['id'], linkData, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errLink = arguments[0];
            return rel = arguments[1];
          };
        })(),
        lineno: 223
      }));
      __iced_deferrals._fulfill();
    })(function() {
      err = errAttr || errLink;
      if (err) {
        return next(err);
      }
      blob = attr.serialize();
      _und.extend(blob, {
        linkData: rel.serialize()
      });
      return res.json(blob);
    });
  };

  exports.voteAttribute = function(req, res, next) {
    var attr, entity, errA, errE, vote, voteData, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "entity.coffee",
        funcname: "voteAttribute"
      });
      Entity.get(req.params.eId, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errE = arguments[0];
            return entity = arguments[1];
          };
        })(),
        lineno: 236
      }));
      Attribute.get(req.params.aId, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errA = arguments[0];
            return attr = arguments[1];
          };
        })(),
        lineno: 237
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (errE) {
        console.log("errE");
        return next(errE);
      }
      if (errA) {
        console.log("errA");
        return next(errA);
      }
      voteData = _und.clone(req.body);
      voteData.ipAddr = req.header['x-forwarded-for'] || req.connection.remoteAddress;
      voteData.browser = req.useragent.Browser;
      voteData.os = req.useragent.OS;
      voteData.lang = req.headers['accept-language'];
      vote = new Vote(voteData);
      return entity.vote(attr, vote, function(err, voteTally) {
        if (err) {
          return res.status(500);
        }
        return res.send(voteTally);
      });
    });
  };

  exports.listRelation = function(req, res, next) {
    var blob, blobs, endId, entityId, err, extraData, ind, query, rel, relType, rels, startId, tmp, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    entityId = req.params.id;
    relType = req.params.relation;
    query = getOutgoingRelsCypherQuery(entityId, relType);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "entity.coffee",
        funcname: "listRelation"
      });
      Neo.query(Link, query, {}, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return rels = arguments[1];
          };
        })(),
        lineno: 265
      }));
      __iced_deferrals._fulfill();
    })(function() {
      blobs = [];
      (function(__iced_k) {
        var _i, _len;
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "entity.coffee",
          funcname: "listRelation"
        });
        for (ind = _i = 0, _len = rels.length; _i < _len; ind = ++_i) {
          rel = rels[ind];
          rel = new Link(rel.r);
          tmp = rel._node._data.start.split('/');
          startId = tmp[tmp.length - 1];
          tmp = rel._node._data.end.split('/');
          endId = tmp[tmp.length - 1];
          extraData = {
            type: rel._node._data.type,
            start: startId,
            end: endId
          };
          rel.serialize(__iced_deferrals.defer({
            assign_fn: (function(__slot_1, __slot_2) {
              return function() {
                return __slot_1[__slot_2] = arguments[0];
              };
            })(blobs, ind),
            lineno: 284
          }), extraData);
        }
        __iced_deferrals._fulfill();
      })(function() {
        return res.json((function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = blobs.length; _i < _len; _i++) {
            blob = blobs[_i];
            _results.push(blob);
          }
          return _results;
        })());
      });
    });
  };

  exports.linkEntity = function(req, res, next) {
    var dstEntity, dst_srcRel, errDst, errSrc, es, et, linkData, linkName, relation, srcEntity, src_dstRel, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "entity.coffee",
        funcname: "linkEntity"
      });
      Entity.get(req.params.srcId, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errSrc = arguments[0];
            return srcEntity = arguments[1];
          };
        })(),
        lineno: 291
      }));
      Entity.get(req.params.dstId, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errDst = arguments[0];
            return dstEntity = arguments[1];
          };
        })(),
        lineno: 292
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (errSrc) {
        return next(errSrc);
      }
      if (errDst) {
        return next(errDst);
      }
      relation = req.body;
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "entity.coffee",
          funcname: "linkEntity"
        });
        if (relation['src_dst']) {
          linkName = Link.normalizeName(relation['src_dst']['name']);
          linkData = Link.deserialize(relation['src_dst']['data']);
          srcEntity._node.createRelationshipTo(dstEntity._node, linkName, linkData, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                es = arguments[0];
                return src_dstRel = arguments[1];
              };
            })(),
            lineno: 307
          }));
        }
        __iced_deferrals._fulfill();
      })(function() {
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "entity.coffee",
            funcname: "linkEntity"
          });
          if (relation['dst_src']) {
            linkName = Link.normalizeName(relation['dst_src']['name']);
            linkData = Link.deserialize(relation['dst_src']['data']);
            dstEntity._node.createRelationshipTo(srcEntity._node, linkName, linkData, __iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  et = arguments[0];
                  return dst_srcRel = arguments[1];
                };
              })(),
              lineno: 317
            }));
          }
          __iced_deferrals._fulfill();
        })(function() {
          return res.status(201).send();
        });
      });
    });
  };

  exports.unlinkEntity = function(req, res, next) {};

}).call(this);

/*
//@ sourceMappingURL=entity.map
*/

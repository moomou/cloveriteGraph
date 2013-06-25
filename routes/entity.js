// Generated by IcedCoffeeScript 1.6.2d
(function() {
  var Attribute, Constants, Entity, Neo, Response, StdSchema, Tag, VoteLink, iced, __iced_k, __iced_k_noop, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  Neo = require('../models/neo');

  Entity = require('../models/entity');

  VoteLink = require('../models/votelink');

  Attribute = require('../models/attribute');

  Tag = require('../models/tag');

  StdSchema = require('../models/stdSchema');

  Constants = StdSchema.Constants;

  Response = StdSchema;

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
          lineno: 21
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
          lineno: 26
        }));
        __iced_deferrals._fulfill();
      })(function() {
        var _i, _len;
        if (err) {
          return next(err);
        }
        for (ind = _i = 0, _len = tagObjs.length; _i < _len; ind = ++_i) {
          tagObj = tagObjs[ind];
          tagObj._node.createRelationshipTo(entity._node, Constants.REL_TAG, function(err, rel) {});
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
            lineno: 35
          }));
          __iced_deferrals._fulfill();
        })(function() {
          return res.status(201).json(blob);
        });
      });
    });
  };

  exports.show = function(req, res, next) {
    var blob, entity, err, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
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
        lineno: 40
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
          funcname: "show"
        });
        entity.serialize(__iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              return blob = arguments[0];
            };
          })(),
          lineno: 43
        }));
        __iced_deferrals._fulfill();
      })(function() {
        return res.json(blob);
      });
    });
  };

  exports.edit = function(req, res, next) {
    var blob, entity, err, ___iced_passed_deferral, __iced_deferrals, __iced_k,
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
        lineno: 48
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
          funcname: "edit"
        });
        entity.serialize(__iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              return blob = arguments[0];
            };
          })(),
          lineno: 51
        }));
        __iced_deferrals._fulfill();
      })(function() {
        return res.json(blob);
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
        lineno: 56
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
          lineno: 59
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          return next(err);
        }
        return res.statusCode(204).send();
      });
    });
  };

  exports.addAttribute = function(req, res, next) {
    var attr, blob, entity, err, errA, errE, rel, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
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
        lineno: 68
      }));
      Attribute.getOrCreate(req.body, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errA = arguments[0];
            return attr = arguments[1];
          };
        })(),
        lineno: 69
      }));
      if (errE) {
        return next(errE);
      }
      if (errA) {
        return next(errA);
      }
      __iced_deferrals._fulfill();
    })(function() {
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "entity.coffee",
          funcname: "addAttribute"
        });
        attr._node.createRelationshipTo(entity._node, Constants.REL_ATTRIBUTE, {}, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return rel = arguments[1];
            };
          })(),
          lineno: 76
        }));
        __iced_deferrals._fulfill();
      })(function() {
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "entity.coffee",
            funcname: "addAttribute"
          });
          (new Neo(rel)).serialize(__iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                return blob = arguments[0];
              };
            })(),
            lineno: 78
          }));
          __iced_deferrals._fulfill();
        })(function() {
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
        lineno: 83
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
        lineno: 84
      }));
      __iced_deferrals._fulfill();
    });
  };

  exports.listAttribute = function(req, res, next) {
    var blob, blobs, entity, err, errE, ind, node, nodes, ___iced_passed_deferral, __iced_deferrals, __iced_k,
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
        lineno: 88
      }));
      __iced_deferrals._fulfill();
    })(function() {
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
          lineno: 91
        }));
        __iced_deferrals._fulfill();
      })(function() {
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
            (new Attribute(node)).serialize(__iced_deferrals.defer({
              assign_fn: (function(__slot_1, __slot_2) {
                return function() {
                  return __slot_1[__slot_2] = arguments[0];
                };
              })(blobs, ind),
              lineno: 96
            }), entity._node.id);
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
        lineno: 103
      }));
      Attribute.get(req.params.aId, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errA = arguments[0];
            return attr = arguments[1];
          };
        })(),
        lineno: 104
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
      vote = new VoteLink(voteData);
      return entity.vote(attr, vote, function(err, voteTally) {
        if (err) {
          return res.statusCode(500);
        }
        return res.send(voteTally);
      });
    });
  };

  exports.listRelation = function(req, res, next) {
    var blob, blobs, entity, err, extraData, ind, rel, relType, rels, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "entity.coffee",
        funcname: "listRelation"
      });
      Entity.get(req.params.id, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return entity = arguments[1];
          };
        })(),
        lineno: 127
      }));
      __iced_deferrals._fulfill();
    })(function() {
      var _ref;
      if (err) {
        return next(err);
      }
      relType = (_ref = req.params.relation) != null ? _ref : '';
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "entity.coffee",
          funcname: "listRelation"
        });
        entity._node.outgoing(relType, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return rels = arguments[1];
            };
          })(),
          lineno: 133
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
            extraData = {
              type: rel.type,
              start: rel.start.id,
              end: rel.end.id
            };
            (new Neo(rel)).serialize(__iced_deferrals.defer({
              assign_fn: (function(__slot_1, __slot_2) {
                return function() {
                  return __slot_1[__slot_2] = arguments[0];
                };
              })(blobs, ind),
              lineno: 145
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
    });
  };

  exports.linkEntity = function(req, res, next) {
    var dstEntity, dst_srcRel, errDst, errSrc, relation, srcEntity, src_dstRel, ___iced_passed_deferral, __iced_deferrals, __iced_k,
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
        lineno: 152
      }));
      Entity.get(req.params.dstId, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errDst = arguments[0];
            return dstEntity = arguments[1];
          };
        })(),
        lineno: 153
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
          srcEntity._node(createRelationshipTo(dstEntity._node, relation['src_dst'], __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                errSrc = arguments[0];
                return src_dstRel = arguments[1];
              };
            })(),
            lineno: 163
          })));
        }
        if (relation['dst_src']) {
          dstEntity._node(createRelationshipTo(dstEntity._node, relation['dst_src'], __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                errDst = arguments[0];
                return dst_srcRel = arguments[1];
              };
            })(),
            lineno: 167
          })));
        }
        __iced_deferrals._fulfill();
      })(function() {
        if (errSrc) {
          return next(errSrc);
        }
        if (errDst) {
          return next(errDst);
        }
        return res.statusCode(202).send();
      });
    });
  };

  exports.unlinkEntity = function(req, res, next) {};

}).call(this);

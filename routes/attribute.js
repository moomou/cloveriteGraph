// Generated by IcedCoffeeScript 1.6.2d
(function() {
  var Attribute, Constants, Entity, Neo, StdSchema, Tag, iced, __iced_k, __iced_k_noop, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  require('source-map-support').install();

  _und = require('underscore');

  Neo = require('../models/neo');

  Entity = require('../models/entity');

  Attribute = require('../models/attribute');

  Tag = require('../models/tag');

  StdSchema = require('../models/stdSchema');

  Constants = StdSchema.Constants;

  exports.search = function(req, res, next) {
    return res.redirect("/search/?q=" + req.query['q']);
  };

  exports.create = function(req, res, next) {
    var attr, blob, err, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "attribute.coffee",
        funcname: "create"
      });
      Attribute.create(req.body, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return attr = arguments[1];
          };
        })(),
        lineno: 20
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return next(err);
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "attribute.coffee",
          funcname: "create"
        });
        attr.serialize(__iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              return blob = arguments[0];
            };
          })(),
          lineno: 23
        }));
        __iced_deferrals._fulfill();
      })(function() {
        return res.json(blob);
      });
    });
  };

  exports.show = function(req, res, next) {
    var attr, blob, entityId, err, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    if (isNaN(req.params.id)) {
      return res.json({});
    }
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "attribute.coffee",
        funcname: "show"
      });
      Attribute.get(req.params.id, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return attr = arguments[1];
          };
        })(),
        lineno: 32
      }));
      __iced_deferrals._fulfill();
    })(function() {
      var _ref;
      if (err) {
        return next(err);
      }
      entityId = (_ref = req.query['entityId']) != null ? _ref : null;
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "attribute.coffee",
          funcname: "show"
        });
        attr.serialize(__iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              return blob = arguments[0];
            };
          })(),
          lineno: 38
        }), entityId);
        __iced_deferrals._fulfill();
      })(function() {
        return res.json(blob);
      });
    });
  };

  exports.edit = function(req, res, next) {
    var attr, blob, err, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "attribute.coffee",
        funcname: "edit"
      });
      Attribute.put(req.params.id, req.body, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return attr = arguments[1];
          };
        })(),
        lineno: 43
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return next(err);
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "attribute.coffee",
          funcname: "edit"
        });
        attr.serialize(__iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              return blob = arguments[0];
            };
          })(),
          lineno: 46
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
        filename: "attribute.coffee",
        funcname: "del"
      });
      Attribute.get(req.params.id, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return entity = arguments[1];
          };
        })(),
        lineno: 51
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return next(err);
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "attribute.coffee",
          funcname: "del"
        });
        entity.del(__iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              return err = arguments[0];
            };
          })(),
          lineno: 54
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

  /*
      Connect another attribute to current one using [relation]
      DATA : {
          action: add/rm
          other: attributeId,
      }
  */


  /*
      List all attribute related to this attribute through [relation]
  */


  exports.listEntity = function(req, res, next) {
    var attr, blob, blobs, err, errAttr, ind, node, nodes, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "attribute.coffee",
        funcname: "listEntity"
      });
      Attribute.get(req.params.id, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            errAttr = arguments[0];
            return attr = arguments[1];
          };
        })(),
        lineno: 75
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (errAttr) {
        return next(errAttr);
      }
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "attribute.coffee",
          funcname: "listEntity"
        });
        attr._node.getRelationshipNodes({
          type: Constants.REL_ATTRIBUTE,
          direction: 'out'
        }, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return nodes = arguments[1];
            };
          })(),
          lineno: 80
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (err) {
          return next(err);
        }
        blobs = [];
        (function(__iced_k) {
          var _i, _len;
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "attribute.coffee",
            funcname: "listEntity"
          });
          for (ind = _i = 0, _len = nodes.length; _i < _len; ind = ++_i) {
            node = nodes[ind];
            (new Entity(node)).serialize(__iced_deferrals.defer({
              assign_fn: (function(__slot_1, __slot_2) {
                return function() {
                  return __slot_1[__slot_2] = arguments[0];
                };
              })(blobs, ind),
              lineno: 87
            }));
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

}).call(this);

/*
//@ sourceMappingURL=attribute.map
*/

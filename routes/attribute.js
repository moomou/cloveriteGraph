// Generated by IcedCoffeeScript 1.6.2d
(function() {
  var Attribute, Constants, Entity, Neo, StdSchema, iced, __iced_k, __iced_k_noop;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  Neo = require('../models/neo');

  Entity = require('../models/entity');

  Attribute = require('../models/attribute');

  StdSchema = require('../models/stdSchema');

  Constants = StdSchema.Constants;

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
        lineno: 10
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
          lineno: 13
        }));
        __iced_deferrals._fulfill();
      })(function() {
        return res.json(blob);
      });
    });
  };

  exports.search = function(req, res, next) {};

  exports.show = function(req, res, next) {
    var attr, blob, err, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
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
        lineno: 21
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
          funcname: "show"
        });
        attr.serialize(__iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              return blob = arguments[0];
            };
          })(),
          lineno: 24
        }));
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
        lineno: 29
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
          lineno: 32
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
        lineno: 37
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
          lineno: 40
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
        lineno: 61
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
          lineno: 66
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
              lineno: 73
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

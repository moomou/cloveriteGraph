// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Logger, Neo, Node, Setup, db, iced, trim, __iced_k, __iced_k_noop, _ref, _und,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  trim = require('../misc/stringUtil').trim;

  Logger = require('util');

  Setup = require('./setup');

  db = Setup.db;

  Neo = (function() {
    function Neo(_node) {
      this._node = _node;
    }

    return Neo;

  })();

  Node = (function(_super) {
    var _MetaSchema, _ToOmitKeys, _del, _load, _save, _update;

    __extends(Node, _super);

    function Node() {
      _ref = Node.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Node.Name = "dummyNeo";

    Node.Schema = {};

    Node.SkipKeys = [];

    Node.ExtraMeta = {};

    Node.Indexes = null;

    Node.Class = null;

    _ToOmitKeys = function() {
      return _und.clone(['id', 'createdAt', 'modifiedAt', 'version', 'nodeType']);
    };


    /*
    # Normal values related to transaction;
    # Permission not implemented here
    */

    _MetaSchema = function() {
      return _und.clone({
        createdAt: -1,
        modifiedAt: -1,
        "private": false,
        version: 0,
        nodeType: ''
      });
    };

    _save = function(obj, cb) {
      if (cb == null) {
        cb = function() {};
      }
      obj._node.data.modifiedAt = new Date().getTime() / 1000;
      if (obj._node.data.createdAt < 0) {
        obj._node.data.createdAt = new Date().getTime() / 1000;
      }
      obj._node.data.version += 1;
      return obj._node.save(function(err) {
        return cb(err);
      });
    };

    _del = function(cb) {
      var delQuery;
      if (cb == null) {
        cb = function() {};
      }
      delQuery = "START n=node(" + this._node.id + ") MATCH n-[r]-() DELETE n, r;";
      return Neo.query(null, delQuery, {}, cb);
    };

    _load = function(id, cb) {
      return db.neo.getNodeById(id, function(err, node) {
        if (err) {
          return cb(err, null);
        }
        return cb(null, node);
      });
    };

    _update = function(newData, obj) {
      console.log("Current Data VER: " + obj._node.data.version);
      console.log("Input Data VER: " + newData.version);
      if (newData.version !== obj._node.data.version) {
        return "Version number incorrect";
      }
      if (!obj._node.data["private"] && newData["private"]) {
        return "Cannot take a public entity and set it to private";
      }
      _und.extend(obj._node.data, newData);
      return false;
    };

    Node.serialize = function(cb, extraData) {
      var data;
      console.log("Serializing");
      if (extraData == null) {
        extraData = {};
      }
      data = this._node.data;
      _und.extend(data, {
        id: this._node.id
      }, extraData);
      if (cb) {
        return cb(data);
      }
      return data;
    };

    Node.create = function(reqBody, indexes, cb) {
      var data, node, obj, saveErr, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      data = this.deserialize(reqBody);
      data = _und.omit(data, _und.extend(_ToOmitKeys(), this.SkipKeys));
      _und.defaults(data, _und.extend(_MetaSchema(), this.ExtraMeta));
      node = db.neo.createNode(data);
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "neoModel.coffee",
          funcname: "Node.create"
        });
        _save(obj, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              return saveErr = arguments[0];
            };
          })(),
          lineno: 94
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (saveErr) {
          return cb(saveErr, null);
        }
        console.log("Starting to index");
        obj = new Neo(node);
        _this.index(obj, obj.serialize());
        console.log("CREATED: " + _this.Name);
        return cb(null, obj);
      });
    };

    Node.show = function(Class, id, cb) {
      return db.neo.getNodeById(id, function(err, node) {
        if (err) {
          return cb(err, null);
        }
        return cb(null, new Class(node));
      });
    };

    Node.update = function(Class, nodeId, reqBody, cb) {
      var data;
      data = Class.deserialize(reqBody);
      console.log("ID: " + nodeId);
      return Class.get(nodeId, function(err, obj) {
        var saveErr, ___iced_passed_deferral, __iced_deferrals, __iced_k,
          _this = this;
        __iced_k = __iced_k_noop;
        ___iced_passed_deferral = iced.findDeferral(arguments);
        if (err) {
          return cb({
            dbError: err
          }, null);
        }
        err = _update(data, obj);
        if (!err) {
          console.log("Saving...");
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "neoModel.coffee"
            });
            _save(obj(__iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  return saveErr = arguments[0];
                };
              })(),
              lineno: 120
            })));
            __iced_deferrals._fulfill();
          })(function() {
            _this.index(obj, obj.serialize());
            if (saveErr) {
              return cb(saveErr, null);
            }
            return cb(null, obj);
            return __iced_k();
          });
        } else {
          console.log("Failed");
          return cb({
            validationError: errMsg
          }, obj);
          return __iced_k();
        }
      });
    };

    Node.fillMetaData = function(data) {
      var cData;
      cData = _und.clone(data);
      _und.extend(cData, MetaSchema);
      cData.createdAt = cData.modifiedAt = new Date().getTime() / 1000;
      cData.version += 1;
      return cData;
    };

    Node.fillIndex = function(indexes, data) {
      var result;
      result = _und.clone(indexes);
      _und.map(result, function(index) {
        return index['INDEX_VALUE'] = encodeURIComponent(trim(data[index['INDEX_KEY']]));
      });
      return _und.filter(result, function(index) {
        return !_und.isUndefined(index['INDEX_VALUE']);
      });
    };

    Node.deserialize = function(ClassSchema, data) {
      var cleaned, validKeys;
      data = _und.clone(data);
      validKeys = ['id', 'version', 'private'];
      validKeys = _und.union(_und.keys(ClassSchema), validKeys);
      _und.defaults(data, ClassSchema);
      cleaned = _und.pick(data, validKeys);
      return cleaned;
    };

    Node.index = function(node, indexes, reqBody, cb) {
      var i, index, _i, _len, _ref1, _results;
      if (cb == null) {
        cb = null;
      }
      console.log("~~~Indexing~~~");
      console.log(reqBody);
      _ref1 = Neo.fillIndex(indexes, reqBody);
      _results = [];
      for (i = _i = 0, _len = _ref1.length; _i < _len; i = ++_i) {
        index = _ref1[i];
        console.log(index);
        _results.push(node.index(index.INDEX_NAME, index.INDEX_KEY, index.INDEX_VALUE, function(err, ind) {
          if (cb && err) {
            cb(err, null);
          }
          if (cb) {
            return cb(null, ind);
          }
        }));
      }
      return _results;
    };

    return Node;

  })(Neo);

  Neo.getRel = function(Class, id, cb) {
    return db.neo.getRelationshipById(id, function(err, rel) {
      if (err) {
        return cb(err, null);
      }
      return cb(null, new Class(rel));
    });
  };

  Neo.putRel = function(Class, relId, reqBody, cb) {
    var data;
    data = Class.deserialize(reqBody);
    return Class.get(relId, function(err, obj) {
      var err, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      if (err) {
        return cb(err, null);
      }
      obj._node.data = data;
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "neoModel.coffee"
        });
        obj._node.save(__iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              return err = arguments[0];
            };
          })(),
          lineno: 185
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (!err) {
          Neo.index(obj._node, Class.Indexes, obj.serialize());
          return cb(null, obj);
        } else {
          console.log("Failed");
          return cb(err, obj);
        }
      });
    });
  };

  Neo.findRel = function(Class, indexName, key, value, cb) {
    return db.neo.getIndexedRelationship(indexName, key, value, function(err, node) {
      if (err) {
        return cb(err, null);
      }
      if (node) {
        return cb(null, new Class(node));
      }
      return cb(null, null);
    });
  };

  Neo.find = function(Class, indexName, key, value, cb) {
    Logger.debug("Neo Find Index: " + indexName);
    Logger.debug("Neo Find Key: " + key);
    Logger.debug("Neo Find Key: " + value);
    return db.neo.getIndexedNode(indexName, key, value, function(err, node) {
      if (err) {
        return cb(err, null);
      }
      if (node) {
        return cb(null, new Class(node));
      }
      return cb(null, null);
    });
  };

  Neo.getOrCreate = function(Class, reqBody, cb) {
    var err, obj, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    if (reqBody['id']) {
      return Class.get(reqBody['id'], cb);
    }
    Logger.debug('Neo Get or Create');
    Logger.debug(Class);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "neoModel.coffee",
        funcname: "getOrCreate"
      });
      Neo.find(Class, Class.INDEX_NAME, 'name', reqBody['name'], __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return obj = arguments[1];
          };
        })(),
        lineno: 228
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (obj) {
        Logger.debug("Neo Find Returned " + Class.Name + ": " + reqBody.toString());
        if (obj) {
          return cb(null, obj);
        }
      }
      return Class.create(reqBody, cb);
    });
  };


  /* Node Specific*/

  Neo.query = function(Class, query, params, cb) {
    return db.neo.query(query, params, function(err, res) {
      if (err) {
        return cb(err, null);
      }
      return cb(null, res);
    });
  };

  Neo.search = function(Class, indexName, query, cb) {
    return db.neo.queryNodeIndex(indexName, query, function(err, nodes) {
      if (err) {
        cb(err);
      }
      return cb(null, _und.map(nodes, function(node) {
        return new Class(node);
      }));
    });
  };

}).call(this);

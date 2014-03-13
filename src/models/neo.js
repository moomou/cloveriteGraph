// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Logger, MetaSchema, Neo, RedisKey, Slug, ToOmitKeys, crypto, db, iced, __iced_k, __iced_k_noop, _und,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  crypto = require('crypto');

  Logger = require('../util/logger');

  Slug = require('../util/slug');

  RedisKey = require('../config').RedisKey;

  db = require('./setup').db;


  /*
  # Normal values related to transaction;
  # Permission not implemented here
  #
  */

  MetaSchema = {
    createdAt: -1,
    modifiedAt: -1,
    "private": false,
    slug: '',
    nodeType: '',
    contributors: [''],
    version: 0
  };

  ToOmitKeys = ['id', 'createdAt', 'modifiedAt', 'version', 'nodeType', 'contributors'];

  module.exports = Neo = (function() {
    function Neo(_node) {
      this._node = _node;
    }

    Neo.prototype.serialize = function(cb, extraData) {
      var data;
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

    Neo.prototype.update = function(newData) {
      Logger.debug("Existing VER: " + this._node.data.version);
      Logger.debug("Modifying VER: " + newData.version);
      if (newData.version !== this._node.data.version) {
        return "Version number incorrect";
      }
      Logger.debug("newData: " + (JSON.stringify(newData)));
      if (!this._node.data["private"] && newData["private"]) {
        return "Cannot take a public entity and set it to private";
      }
      this._node.data = _und.extend(this._node.data, newData);
      db.redis.hdel(RedisKey.slugToId, this._node.data.slug, function(err) {});
      return false;
    };

    Neo.prototype.save = function(cb) {
      if (cb == null) {
        cb = function() {};
      }
      this._node.data.modifiedAt = new Date().getTime() / 1000;
      if (this._node.data.createdAt < 0) {
        this._node.data.createdAt = new Date().getTime() / 1000;
      }
      this._node.data.version += 1;
      Logger.debug("Saving: " + (JSON.stringify(this._node.data)));
      return this._node.save(function(err) {
        return cb(err);
      });
    };

    Neo.prototype.del = function(cb) {
      var delQuery;
      if (cb == null) {
        cb = function() {};
      }
      delQuery = "START n=node(" + this._node.id + ") MATCH n-[r]-() DELETE n, r;";
      return Neo.query(null, delQuery, {}, cb);
    };

    return Neo;

  })();

  Neo.MetaSchema = MetaSchema;

  Neo.fillMetaData = function(data) {
    var cData;
    cData = _und.clone(data);
    _und.extend(cData, MetaSchema);
    cData.createdAt = cData.modifiedAt = new Date().getTime() / 1000;
    cData.version += 1;
    return cData;
  };

  Neo.fillIndex = function(indexes, data) {
    var result;
    result = _und.clone(indexes);
    data = _und.clone(data);
    result = _und(result).filter(function(index) {
      return index.INDEX_VALUE = encodeURIComponent(data[index.INDEX_KEY].trim());
    });
    return _und(result).filter(function(index) {
      return !_und.isUndefined(index.INDEX_VALUE);
    });
  };

  Neo.deserialize = function(ClassSchema, data) {
    var cleaned, validKeys;
    data = _und.clone(data);
    validKeys = ['id', 'version', 'private'];
    validKeys = _und.union(_und.keys(ClassSchema), validKeys);
    cleaned = _und.defaults(data, ClassSchema);
    return _und.pick(data, validKeys);
  };

  Neo.parseReqBody = function(Class, reqBody) {
    var data, hash, md5sum, user;
    if (reqBody.user) {
      user = reqBody.user.serialize();
    } else {
      user = {
        username: "anonymous",
        email: "anonymous"
      };
    }
    data = Class.deserialize(reqBody);
    data = _und.omit(data, ToOmitKeys);
    if (Class.getSlugTitle) {
      data.slug = Class.getSlugTitle(reqBody);
    }
    if (data.contributors == null) {
      data.contributors = [];
    }
    if (user) {
      md5sum = crypto.createHash('md5');
      md5sum.update(user.email.trim());
      hash = md5sum.digest('hex');
      Logger.debug("Email: " + user.email);
      Logger.debug("Hash: " + hash);
      if (__indexOf.call(data.contributors, hash) < 0) {
        data.contributors.push(hash);
      }
    }
    return data;
  };

  Neo.index = function(node, indexes, reqBody, cb) {
    var i, index, _i, _len, _ref, _results;
    if (cb == null) {
      cb = null;
    }
    Logger.debug("%%%~~~Indexing~~~%%%");
    Logger.debug("Data: " + reqBody);
    _ref = Neo.fillIndex(indexes, reqBody);
    _results = [];
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      index = _ref[i];
      Logger.debug("Index: " + index);
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

  Neo.create = function(Class, reqBody, indexes, cb) {
    var data, err, node, obj, res, saveErr, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    Logger.debug("Creating " + Class + " using : " + reqBody);
    data = Neo.parseReqBody(Class, reqBody);
    _und.defaults(data, MetaSchema);
    node = db.neo.createNode(data);
    obj = new Class(node);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "neo.coffee",
        funcname: "create"
      });
      obj.save(__iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            return saveErr = arguments[0];
          };
        })(),
        lineno: 177
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (saveErr) {
        return cb(saveErr, null);
      }
      Logger.debug("CREATED: " + Class.Name);
      Neo.index(node, Class.Indexes, obj.serialize());
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "neo.coffee",
          funcname: "create"
        });
        db.redis.hset(RedisKey.slugToId, node.data.slug, node.id, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              err = arguments[0];
              return res = arguments[1];
            };
          })(),
          lineno: 185
        }));
        __iced_deferrals._fulfill();
      })(function() {
        return cb(null, obj);
      });
    });
  };

  Neo.get = function(Class, id, cb) {
    return db.neo.getNodeById(id, function(err, node) {
      if (err) {
        return cb(err, null);
      }
      return cb(null, new Class(node));
    });
  };

  Neo.put = function(Class, nodeId, reqBody, cb) {
    var data;
    Logger.debug("" + Class.name + " put: " + (JSON.stringify(reqBody)));
    data = Neo.parseReqBody(Class, reqBody);
    data.version = reqBody.version;
    return Class.get(nodeId, function(err, obj) {
      var errMsg, saveErr, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      if (err) {
        return cb({
          dbError: err
        }, null);
      }
      errMsg = obj.update(data);
      if (!errMsg) {
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "neo.coffee"
          });
          obj.save(__iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                return saveErr = arguments[0];
              };
            })(),
            lineno: 205
          }));
          __iced_deferrals._fulfill();
        })(function() {
          Neo.index(obj._node, Class.Indexes, obj.serialize());
          return __iced_k(saveErr ? cb(saveErr, null) : cb(null, obj));
        });
      } else {
        return cb({
          validationError: errMsg
        }, obj);
        return __iced_k();
      }
    });
  };

  Neo.find = function(Class, indexName, key, value, cb) {
    Logger.debug("Neo Find Index: " + indexName);
    Logger.debug("Neo Find Key: " + key);
    Logger.debug("Neo Find Value: " + value);
    Logger.debug("Neo CB : " + cb);
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
    if (reqBody.id) {
      return Class.get(reqBody.id, cb);
    }
    Logger.debug("" + Class + "Get or Create");
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "neo.coffee",
        funcname: "getOrCreate"
      });
      Neo.find(Class, Class.INDEX_NAME, 'slug', Class.getSlugTitle(reqBody), __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return obj = arguments[1];
          };
        })(),
        lineno: 240
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (obj) {
        Logger.debug("Neo Find Returned " + Class.Name + ": " + reqBody.toString());
        return cb(null, obj);
      } else {
        Logger.debug("Neo didn't find anything");
        return Class.create(reqBody, cb);
      }
    });
  };

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
          filename: "neo.coffee"
        });
        obj._node.save(__iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              return err = arguments[0];
            };
          })(),
          lineno: 263
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (!err) {
          Neo.index(obj._node, Class.Indexes, obj.serialize());
          return cb(null, obj);
        } else {
          Logger.error("" + Class + " putRel Failed");
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

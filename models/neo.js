// Generated by IcedCoffeeScript 1.6.2d
(function() {
  var MetaSchema, Neo, Setup, db, iced, __iced_k, __iced_k_noop, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  Setup = require('./setup');

  db = Setup.db;

  MetaSchema = {
    createdAt: -1,
    modifiedAt: -1,
    "private": false,
    version: 0
  };

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
      if (newData.version !== this._node.data.version) {
        return false;
      }
      _und.extend(this._node.data, newData);
      return true;
    };

    Neo.prototype.save = function(cb) {
      this._node.data.modifiedAt = new Date().getTime() / 1000;
      if (this._node.data.createdAt < 0) {
        this._node.data.createdAt = new Date().getTime() / 1000;
      }
      this._node.data.version += 1;
      return this._node.save(function(err) {
        return cb(err);
      });
    };

    Neo.prototype.del = function(cb) {
      return this._node.del(function(err) {
        return cb(err, true);
      });
    };

    return Neo;

  })();

  Neo.deserialize = function(ClassSchema, data) {
    _und.defaults(data, ClassSchema);
    return data;
  };

  Neo.create = function(Class, reqBody, index, cb) {
    var data, indexErr, node, obj, saveErr, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    data = Class.deserialize(reqBody);
    _und.extend(data, MetaSchema);
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
        lineno: 55
      }));
      __iced_deferrals._fulfill();
    })(function() {
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "neo.coffee",
          funcname: "create"
        });
        node.index(index.INDEX_NAME, index.INDEX_KEY, index.INDEX_VAL, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              return indexErr = arguments[0];
            };
          })(),
          lineno: 61
        }));
        __iced_deferrals._fulfill();
      })(function() {
        if (saveErr) {
          return cb(saveErr, null);
        }
        if (indexErr) {
          return cb(indexErr, null);
        }
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
    return Neo.get(Class, nodeId, function(err, obj) {
      var valid;
      if (err) {
        return cb(err, null);
      }
      valid = obj.update(reqBody);
      if (valid) {
        obj.save(function(err) {
          if (err) {
            return cb(err, null);
          }
          return cb(null, obj);
        });
      }
      return cb(err, null);
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

  Neo.createLink = function(srcNode, destNode, linkName, linkData, cb) {};

}).call(this);

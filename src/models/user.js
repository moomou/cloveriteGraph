// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Constants, INDEX_NAME, Indexes, Logger, Neo, SchemaUtil, SchemaValidation, ToOmitKeys, User, UserSchema, redis, _und,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };



  Logger = require('util');

  _und = require('underscore');

  redis = require('./setup').db.redis;

  Neo = require('./neo');

  Constants = require('../config').Constants;

  SchemaUtil = require('./stdSchema');

  INDEX_NAME = 'nUser';

  Indexes = [
    {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'accessToken',
      INDEX_VALUE: ''
    }, {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'username',
      INDEX_VALUE: ''
    }, {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'email',
      INDEX_VALUE: ''
    }
  ];

  UserSchema = {
    email: '',
    username: '',
    accessToken: '',
    reputation: 'Z',
    createdCount: 0,
    modifiedCount: 0
  };

  SchemaValidation = {
    email: SchemaUtil.required('string'),
    username: SchemaUtil.required('string')
  };

  ToOmitKeys = ["contributors", "slug"];

  module.exports = User = (function(_super) {
    __extends(User, _super);

    function User(_node) {
      this._node = _node;
      User.__super__.constructor.call(this, this._node);
    }

    User.prototype.serialize = function(cb, extraData) {
      var data;
      data = this._node.data;
      _und.extend(data, {
        id: this._node.id
      }, extraData);
      if (cb) {
        return cb(_und.omit(data, ToOmitKeys));
      } else {
        return _und.omit(data, ToOmitKeys);
      }
    };

    return User;

  })(Neo);

  User.Name = 'nUser';

  User.INDEX_NAME = INDEX_NAME;

  User.Indexes = Indexes;

  User.validateSchema = function(data) {
    return SchemaUtil.validate(SchemaValidation, data);
  };

  User.deserialize = function(data) {
    var cleaned;
    cleaned = Neo.deserialize(UserSchema, data);
    return _und.omit(cleaned, ToOmitKeys);
  };

  User.create = function(reqBody, cb) {
    reqBody["private"] = true;
    return Neo.create(User, reqBody, Indexes, cb);
  };

  User.get = function(id, cb) {
    var digitOnly;
    digitOnly = /^\d+$/.test(id);
    if (digitOnly) {
      return Neo.get(User, id, cb);
    } else {
      return Neo.find(User, User.INDEX_NAME, 'username', id, cb);
    }
  };

  User.getOrCreate = function(reqBody, cb) {
    throw "User getOrCreate Not Implemented";
  };

  User.put = function(nodeId, reqBody, cb) {
    return Neo.put(User, nodeId, reqBody, cb);
  };

  User.find = function(key, value, cb) {
    return Neo.find(User, User.INDEX_NAME, key, value, cb);
  };

}).call(this);

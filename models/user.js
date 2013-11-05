// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Constants, INDEX_NAME, Indexes, Logger, Neo, SchemaUtil, SchemaValidation, Setup, User, UserSchema, redis, _und,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };



  _und = require('underscore');

  Logger = require('util');

  Neo = require('./neo');

  Setup = require('./setup');

  redis = Setup.db.redis;

  SchemaUtil = require('./stdSchema');

  Constants = SchemaUtil.Constants;

  INDEX_NAME = 'nUser';

  Indexes = [
    {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'reputation',
      INDEX_VALUE: ''
    }, {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'accessToken',
      INDEX_VALUE: ''
    }, {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'lastname',
      INDEX_VALUE: ''
    }, {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'firstname',
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
    firstname: '',
    lastname: '',
    accessToken: '',
    reputation: 'Z',
    createdCount: 0,
    modifiedCount: 0
  };

  SchemaValidation = {
    email: SchemaUtil.required('string'),
    username: SchemaUtil.required('string'),
    firstname: SchemaUtil.required('string'),
    lastname: SchemaUtil.required('string')
  };

  module.exports = User = (function(_super) {
    __extends(User, _super);

    function User(_node) {
      this._node = _node;
      User.__super__.constructor.call(this, this._node);
    }

    return User;

  })(Neo);

  User.Name = 'nUser';

  User.INDEX_NAME = INDEX_NAME;

  User.Indexes = Indexes;

  User.validateSchema = function(data) {
    return SchemaUtil.validate(SchemaValidation, data);
  };

  User.deserialize = function(data) {
    return Neo.deserialize(UserSchema, data);
  };

  User.create = function(reqBody, cb) {
    return Neo.create(User, reqBody, Indexes, cb);
  };

  User.get = function(id, cb) {
    return Neo.get(User, id, cb);
  };

  User.getOrCreate = function(reqBody, cb) {
    throw "Not Implemented";
  };

  User.put = function(nodeId, reqBody, cb) {
    return Neo.put(User, nodeId, reqBody, cb);
  };

  User.find = function(key, value, cb) {
    return Neo.find(User, User.INDEX_NAME, key, value, cb);
  };

}).call(this);

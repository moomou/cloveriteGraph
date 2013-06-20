// Generated by IcedCoffeeScript 1.6.2d
(function() {
  var File, FileSchema, Meta, Neo, Setup, redis, _und,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };



  _und = require('underscore');

  Setup = require('./setup');

  Neo = require('./neo');

  Meta = require('./meta');

  redis = Setup.db.redis;

  FileSchema = {
    name: "Name of file",
    type: "",
    tags: [""],
    content: "",
    url: "",
    version: 0,
    "private": false
  };

  module.exports = File = (function(_super) {
    __extends(File, _super);

    function File(_node) {
      this._node = _node;
      File.__super__.constructor.call(this, this._node);
    }

    return File;

  })(Neo);

}).call(this);

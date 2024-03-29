// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Logger, Neo, RequestSchema, SchemaUtil, SchemaValidation, Setup, _und;



  _und = require('underscore');

  Logger = require('../util/logger');

  Setup = require('./setup');

  Neo = require('./neo');

  SchemaUtil = require('./stdSchema');

  RequestSchema = {
    to: '',
    from: '',
    request: ''
  };

  SchemaValidation = {};

  module.exports = {
    name: "requestFeed",
    validateSchema: function(data) {
      return SchemaUtil.validate(SchemaValidation, data);
    },
    deserialize: function(data) {
      return Neo.deserialize(RequestSchema, data);
    },
    fillMetaData: function(data) {
      return Neo.fillMetaData(data);
    }
  };

}).call(this);

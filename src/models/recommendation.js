// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Logger, Neo, RecommendationSchema, SchemaUtil, SchemaValidation, _und;



  _und = require('underscore');

  Logger = require('../util/logger');

  Neo = require('./neo');

  SchemaUtil = require('./stdSchema');

  RecommendationSchema = {
    to: '',
    from: '',
    content: ['']
  };

  SchemaValidation = {};

  module.exports = {
    name: "recommendationFeed",
    validateSchema: function(data) {
      return SchemaUtil.validate(SchemaValidation, data);
    },
    deserialize: function(data) {
      return Neo.deserialize(RecommendationSchema, data);
    },
    fillMetaData: function(data) {
      return Neo.fillMetaData(data);
    }
  };

}).call(this);

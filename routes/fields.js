// Generated by IcedCoffeeScript 1.6.3-e

/*
# Responsible for parsing query parameters
*/

(function() {
  var DEFAULT_CONFIG, _und;



  _und = require('underscore');

  DEFAULT_CONFIG = {
    fields: ["*"],
    limit: 1000,
    offset: 0,
    expand: {}
  };

  exports.parseQuery = function(req) {
    var params, queryParams;
    params = req.query;
    queryParams = _und.clone(DEFAULT_CONFIG);
    if (params.fields) {
      queryParams.fields = params.fields.split(",");
    }
    if (params.limit) {
      queryParams.limit = parseInt(limit);
    }
    if (params.offset) {
      queryParams.offset = parseInt(offset);
    }
    return queryParams;
  };

}).call(this);
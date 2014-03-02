// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Constants, Data, ErrorDevMessage, Neo, Response, Tag, iced, __iced_k, __iced_k_noop, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  require('source-map-support').install();

  _und = require('underscore');

  Neo = require('../models/neo');

  Data = require('../models/data');

  Tag = require('../models/tag');

  Constants = require('../config').Constants;

  Response = require('./util/response');

  ErrorDevMessage = Response.ErrorDevMessage;

  exports.show = function(req, res, next) {
    var data, err, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    if (isNaN(req.params.id)) {
      return Response.ErrorResponse(res)(400, ErrorDevMessage.missingParam('id'));
    }
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "data.coffee",
        funcname: "show"
      });
      Data.get(req.params.id, __iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            err = arguments[0];
            return data = arguments[1];
          };
        })(),
        lineno: 22
      }));
      __iced_deferrals._fulfill();
    })(function() {
      if (err) {
        return Response.ErrorResponse(res)(500, ErrorDevMessage.dbIssue());
      }
      return Response.OKResponse(res)(200, data.serialize());
    });
  };

}).call(this);
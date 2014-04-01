// Generated by IcedCoffeeScript 1.6.3-e

/*
# Responsible for delivering user facing data
*/

(function() {
  var DEFAULT_RESPONSE, DOC_LINK, DevMessageGenerator, MessageGen, createErrorDetailObj, errorMessage, _und;



  _und = require('underscore');

  DEFAULT_RESPONSE = {
    success: true,
    payload: null,
    httpCode: null,
    error: null,
    next: null,
    prev: null
  };

  MessageGen = {
    '400': "Please check all required fields are provided and correct.",
    '500': "Oops. That didn't work. Please try again. If the problem persists, please notify us.",
    '403': "Permission denied"
  };

  DevMessageGenerator = {
    customMsg: function(msg) {
      return msg;
    },
    missingParam: function(paramName) {
      return "Missing required field: " + paramName + ".";
    },
    dbIssue: function() {
      return "Connection problems with internal db. Please try again later.";
    },
    notFound: function() {
      return "Requested resource does not exist.";
    },
    permissionIssue: function() {
      return "The user does not have permission.";
    },
    dataValidationIssue: function(msg) {
      return "Data issue: " + msg;
    },
    notImplemented: function() {
      return "Not Implemented.";
    }
  };

  DOC_LINK = {};

  createErrorDetailObj = function(devMsg, msg, docLink) {
    return {
      message: msg || null,
      devMessage: devMsg || msg || null,
      documentation: docLink || null
    };
  };

  errorMessage = function(httpCode) {
    return MessageGen[httpCode.toString()];
  };

  exports.ErrorDevMessage = DevMessageGenerator;

  exports.ErrorResponse = function(res) {
    return function(httpCode, devMsg, docLink) {
      var response;
      response = _und.clone(DEFAULT_RESPONSE);
      response.success = false;
      response.httpCode = httpCode;
      response.error = createErrorDetailObj(devMsg, errorMessage(httpCode), docLink);
      return res.status(httpCode).json(response);
    };
  };

  exports.OKResponse = function(res) {
    return function(httpCode, payload, next, prev) {
      var response;
      response = _und.clone(DEFAULT_RESPONSE);
      response.payload = payload;
      response.httpCode = httpCode;
      response.next = next;
      response.prev = prev;
      return res.status(httpCode).json(response);
    };
  };

  exports.JSResponse = function(res) {
    return function(httpCode, payload, next, prev) {
      res.setHeader("Content-Type", "text/javascript");
      return res.status(httpCode).end(payload);
    };
  };

}).call(this);

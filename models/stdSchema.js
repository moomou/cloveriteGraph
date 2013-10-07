// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Constants, ErrorResponse, Validators, validationSchema, _und, _validator,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };



  _und = require('underscore');

  _validator = function(valid, validate, input) {
    if (!valid) {
      return [false, input];
    }
    valid = validate(input);
    return [valid, input];
  };

  Validators = {
    string: function(state, input) {
      return _validator(state, _und.isString, input);
    },
    number: function(state, input) {
      return _validator(state, _und.isNumber, input);
    },
    array: function(state, input) {
      return _validator(state, _und.isArray, input);
    }
  };

  validationSchema = function(required, validator) {
    if (!_und.isFunction(validator)) {
      validator = Validators[(_und.values(validator))[0]];
    }
    return {
      required: required,
      validator: validator
    };
  };

  exports.validate = function(schemaValidation, input) {
    var result;
    result = _und.map(schemaValidation, function(value, key) {
      var valid, _, _ref, _ref1;
      console.log(key);
      if (value.required) {
        console.log("REQUIRED");
        if (!input[key]) {
          return false;
        }
        _ref = value.validator(true, input[key]), valid = _ref[0], _ = _ref[1];
        return valid;
      } else if (__indexOf.call(input, key) >= 0) {
        console.log("OPTIONAL");
        _ref1 = value.validator(true, input[key]), valid = _ref1[0], _ = _ref1[1];
        return valid;
      } else {
        return true;
      }
    });
    console.log(result);
    if (_und.contains(result, false)) {
      return false;
    }
    return true;
  };

  exports.required = function() {
    return validationSchema(true, arguments);
  };

  exports.optional = function() {
    return validationSchema(false, arguments);
  };

  exports.Constants = Constants = {
    API_VERSION: 'v0',
    TAG_GLOBAL: '__global__',
    REL_LOCATION: '_LOCATION',
    REL_AWARD: '_AWARD',
    REL_ATTRIBUTE: '_ATTRIBUTE',
    REL_PARENT: '_PARENT',
    REL_CHILD: '_CHILD',
    REL_CONTAINER: '_CONTAINER',
    REL_RESOURCE: '_RESOURCE',
    REL_TAG: '_TAG',
    REL_ACCESS: '_ACCESS',
    REL_RANK: '_RANK',
    REL_RANKING: '_RANKING',
    REL_VOTED: '_VOTED',
    REL_COMMENTED: '_COMMENTED',
    REL_CREATED: '_CREATED',
    REL_MODIFIED: '_MODIFIED',
    ATTR_NUMERIC: "attr_numeric",
    ATTR_REFERENCE: "attr_ref"
  };


  /*
      Relationship Schema
  */

  exports.ErrorResponse = ErrorResponse = (function() {
    function ErrorResponse(msg, fix) {
      this.msg = msg;
      this.fix = fix;
    }

    ErrorResponse.prototype.serialize = function() {
      return {
        message: this.msg,
        solution: this.fix
      };
    };

    return ErrorResponse;

  })();

}).call(this);

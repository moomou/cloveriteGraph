// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Constants, INDEX_NAME, Indexes, Logger, SchemaUtil, Vote, VoteSchema, _und;



  Logger = require('util');

  _und = require('underscore');

  SchemaUtil = require('./stdSchema');

  Constants = require('../config').Constants;

  INDEX_NAME = 'rVote';

  Indexes = [
    {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'user',
      INDEX_VALUE: ''
    }, {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'os',
      INDEX_VALUE: ''
    }, {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'lang',
      INDEX_VALUE: ''
    }
  ];

  VoteSchema = {
    attrId: '',
    attrName: '',
    tone: '',
    user: '',
    time: '',
    ipAddr: '',
    lang: '',
    browser: '',
    os: '',
    rating: 0
  };

  module.exports = Vote = (function() {
    function Vote(voteData) {
      var data;
      this.name = Constants.REL_VOTED;
      Logger.debug("Creating vote data: " + voteData);
      data = _und.clone(voteData);
      data = _und.defaults(data, VoteSchema);
      data = _und.pick(data, _und.keys(VoteSchema));
      this.data = data;
      if (!this.data.time) {
        this.data.time = '' + new Date().getTime() / 1000;
      }
    }

    return Vote;

  })();


  /*
  Static Method
  */

  Vote.Name = 'rVote';

  Vote.INDEX_NAME = INDEX_NAME;

}).call(this);

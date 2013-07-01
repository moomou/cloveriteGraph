// Generated by IcedCoffeeScript 1.6.2d
(function() {
  var Contants, INDEX_NAME, Indexes, StdSchema, Vote, VoteSchema, _und;



  _und = require('underscore');

  StdSchema = require('./stdSchema');

  Contants = StdSchema.Contants;

  INDEX_NAME = 'rVote';

  Indexes = [
    {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'name',
      INDEX_VALUE: ''
    }, {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'description',
      INDEX_VALUE: ''
    }, {
      INDEX_NAME: INDEX_NAME,
      INDEX_KEY: 'description',
      INDEX_VALUE: ''
    }
  ];

  VoteSchema = {
    type: '',
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
      this.name = Contants.REL_VOTE;
      data = _und.clone(voteData);
      _und.defaults(data, VoteSchema);
      _und.pick(data, _under.keys(VoteSchema));
      this.data = data;
      if (!this.data.time) {
        this.data.time = '' + new Date().getTime();
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

/*
//@ sourceMappingURL=votelink.map
*/

// Generated by IcedCoffeeScript 1.6.2d
/*
    Relationship Schema
*/


(function() {
  var Relation, Vote;



  Vote = (function() {
    function Vote(type, ipAddr, user, time, lang, agent, rating) {
      this.type = type;
      this.ipAddr = ipAddr;
      this.user = user;
      this.time = time;
      this.lang = lang;
      this.agent = agent;
      this.rating = rating;
    }

    return Vote;

  })();

  Relation = (function() {
    function Relation(linkName) {
      this.linkName = linkName;
    }

    return Relation;

  })();

}).call(this);

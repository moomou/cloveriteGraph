// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var api, apiVersion, app, assert, chai, should, supertest;



  supertest = require('supertest');

  chai = require('chai');

  should = chai.should();

  assert = chai.assert;

  app = require('../app').app;

  api = supertest(app);

  apiVersion = app.version;

  describe('Rank', function() {
    var entityIds, rankId, userId, userToken, username;
    entityIds = [];
    rankId = null;
    userToken = null;
    username = null;
    userId = null;
    before(function(done) {
      var randomId;
      randomId = '#' + (Math.random() * 0xFFFFFF << 0).toString(16);
      return api.post("" + apiVersion + "/entity/").send({
        name: randomId
      }).end(function(err, res) {
        var response;
        response = JSON.parse(res.text);
        entityIds.push(response.payload.id);
        return done();
      });
    });
    before(function(done) {
      var randomId;
      randomId = '#' + (Math.random() * 0xFFFFFF << 0).toString(16);
      return api.post("" + apiVersion + "/entity/").send({
        name: randomId
      }).end(function(err, res) {
        var response;
        response = JSON.parse(res.text);
        entityIds.push(response.payload.id);
        return done();
      });
    });
    before(function(done) {
      return api.post("" + apiVersion + "/user").set("x-access-token", "superman").send({
        username: "TEST_rankTestUser",
        email: "rankTestUser@cloverite.com"
      }).end(function(err, res) {
        var response;
        response = JSON.parse(res.text);
        userToken = response.payload.accessToken;
        username = response.payload.username;
        userId = response.payload.id;
        return done();
      });
    });
    return it('should return 201 when creating new ranking', function(done) {
      return api.post("" + apiVersion + "/user/" + userId + "/ranking").send({
        name: "TEST_ranking",
        ranks: entityIds
      }).set('x-access-token', userToken).expect(201).end(function(err, res) {
        var response;
        response = JSON.parse(res.text);
        response.payload.should.have.id;
        response.payload.ranks.should.eql(entityIds);
        response.payload.contributors.should.eql(['38d692b2f557313d1e548b59d0feb915']);
        response.payload.shareToken.should.not.eq('');
        console.log(response.payload);
        return done();
      });
    });
  });

}).call(this);

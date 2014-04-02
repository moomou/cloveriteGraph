// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var api, apiVersion, app, assert, chai, randomId, should, supertest;



  supertest = require('supertest');

  chai = require('chai');

  should = chai.should();

  assert = chai.assert;

  app = require('../app').app;

  api = supertest(app);

  apiVersion = app.version;

  randomId = '#' + (Math.random() * 0xFFFFFF << 0).toString(16);

  describe('User', function() {
    describe('creation', function() {
      it('creation should return 201 when creating user with privileged token', function(done) {
        return api.post("" + apiVersion + "/user").set("x-access-token", "superman").send({
          username: "TEST_" + randomId,
          email: "" + randomId + "@me.com"
        }).expect(201).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          assert.isNumber(response.payload.id);
          assert.isString(response.payload.accessToken);
          response.payload.should.have.property('username', "TEST_" + randomId);
          return done();
        });
      });
      it('creation should return 403 when creating user with bad token', function(done) {
        return api.post("" + apiVersion + "/user").set("x-access-token", "wonder woman").send({
          username: "TEST_" + randomId,
          email: "" + randomId + "@me.com"
        }).expect(403, done);
      });
      return it('creation should return 400 when creating user incorrect info', function(done) {
        return api.post("" + apiVersion + "/user").set("x-access-token", "superman").send({
          username: "TEST_" + randomId
        }).expect(400, done);
      });
    });
    return describe('detail', function() {
      var otherId, otherToken, othername, privateEntityId, publicEntityId, userId, userToken, username;
      username = null;
      userId = null;
      userToken = null;
      othername = null;
      otherId = null;
      otherToken = null;
      publicEntityId = null;
      privateEntityId = null;
      before(function(done) {
        return api.post("" + apiVersion + "/user").set("x-access-token", "superman").send({
          username: "TEST_entityTestUser",
          email: "entityTestUser@cloverite.com"
        }).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          userToken = response.payload.accessToken;
          username = response.payload.username;
          userId = response.payload.id;
          return done();
        });
      });
      before(function(done) {
        return api.post("" + apiVersion + "/user").set("x-access-token", "superman").send({
          username: "TEST_entityTestOther",
          email: "entityTestOther@cloverite.com"
        }).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          othername = response.payload.username;
          otherId = response.payload.id;
          otherToken = response.payload.accessToken;
          return done();
        });
      });
      before(function(done) {
        return api.post("" + apiVersion + "/entity/").set("x-access-token", otherToken).send({
          name: 'private',
          "private": true
        }).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          privateEntityId = response.payload.id;
          return done();
        });
      });
      before(function(done) {
        return api.post("" + apiVersion + "/entity/").set("x-access-token", otherToken).send({
          name: 'public'
        }).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          response.payload.should.have.property('id');
          publicEntityId = response.payload.id;
          return done();
        });
      });
      it('should return 200 with private info when accessing', function(done) {
        return api.get("" + apiVersion + "/user/" + otherId).set("x-access-token", otherToken).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          response.payload.accessToken.should.not.be["null"];
          response.success.should.equal(true);
          return done();
        });
      });
      it('should return 200 with public info when accessing', function(done) {
        return api.get("" + apiVersion + "/user/" + otherId).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          assert.isUndefined(response.payload.accessToken);
          response.success.should.equal(true);
          return done();
        });
      });
      it('should only see public created when accessing other user', function(done) {
        return api.get("" + apiVersion + "/user/" + otherId + "/created").set("x-access-token", userToken).end(function(err, res) {
          var response, returnedIds;
          response = JSON.parse(res.text);
          response.success.should.equal(true);
          returnedIds = response.payload.map(function(obj) {
            return obj.id;
          });
          returnedIds.should.eql([publicEntityId]);
          return done();
        });
      });
      it('should see both private and public created when accessing self', function(done) {
        return api.get("" + apiVersion + "/user/" + otherId + "/created").set("x-access-token", otherToken).end(function(err, res) {
          var response, returnedIds;
          response = JSON.parse(res.text);
          response.success.should.equal(true);
          returnedIds = response.payload.map(function(obj) {
            return obj.id;
          });
          returnedIds.should.eql([privateEntityId, publicEntityId]);
          return done();
        });
      });
      return it('should allow access to private info if shared', function(done) {
        return assert.isNull("NOT DONE");
      });
    });
  });

}).call(this);

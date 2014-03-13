// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var api, apiVersion, app, assert, chai, should, supertest;



  supertest = require('supertest');

  chai = require('chai');

  assert = chai.assert;

  should = chai.should();

  app = require('../app').app;

  api = supertest(app);

  apiVersion = app.version;

  describe('Entity', function() {
    var attributeName, dataName, entityName, newAttributeId, newDataId, newEntityId, privateEntityId, userToken, username;
    newEntityId = null;
    newAttributeId = null;
    newDataId = null;
    userToken = null;
    username = null;
    privateEntityId = null;
    entityName = "TEST_mocha";
    attributeName = "TEST_attr";
    dataName = "TEST_data";
    describe('with user', function() {
      before(function(done) {
        return api.post("" + apiVersion + "/user").set("x-access-token", "superman").send({
          username: "TEST_entityTestUser",
          email: "entityTestUser@cloverite.com"
        }).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          userToken = response.payload.accessToken;
          username = response.payload.username;
          return done();
        });
      });
      it('can create private data', function(done) {
        return api.post("" + apiVersion + "/entity/").set("x-access-token", userToken).send({
          name: 'random',
          "private": true
        }).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          response.payload.should.have.property('id');
          response.payload.should.have.property('private', true);
          response.payload.contributors.should.eql(['7a98f7f5a429f6cf385547495d84107f']);
          response.success.should.equal(true);
          privateEntityId = response.payload.id;
          return done();
        });
      });
      it('private entity is accessible.', function(done) {
        return api.get("" + apiVersion + "/entity/" + privateEntityId).set("x-access-token", userToken).expect(200, done);
      });
      it('can retrieve created', function(done) {
        return assert.isNull(true);
      });
      it('can retrieve modified', function(done) {
        return assert.isNull(true);
      });
      return it('can retrieve subscription', function(done) {
        return assert.isNull(true);
      });
    });
    return describe('with guest', function() {
      it('should return 400 when entity does not exist', function(done) {
        return api.get("" + apiVersion + "/entity/xyz").expect(400, done);
      });
      it('should hide private entity.', function(done) {
        return api.get("" + apiVersion + "/entity/" + privateEntityId).expect(401, done);
      });
      it('should return 201 when adding new entity', function(done) {
        return api.post("" + apiVersion + "/entity/").send({
          name: entityName
        }).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          response.payload.should.have.property('id');
          response.payload.should.have.property('imgURL');
          response.success.should.equal(true);
          newEntityId = response.payload.id;
          return done();
        });
      });
      it('should return 200 when getting existing entity', function(done) {
        return api.get("" + apiVersion + "/entity/" + newEntityId).expect(200, done);
      });
      it('should return 200 when updating existing entity', function(done) {
        return api.put("" + apiVersion + "/entity/" + newEntityId).send({
          name: entityName + "1",
          version: 1,
          description: "what"
        }).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          response.payload.should.have.property("version", 2);
          return api.get("" + apiVersion + "/entity/" + newEntityId).end(function(err, res) {
            response = JSON.parse(res.text);
            response.payload.should.have.property("name", "" + entityName + "1");
            return done();
          });
        });
      });
      it('should return 200 when getting existing entity', function(done) {
        return api.get("" + apiVersion + "/entity/" + newEntityId).expect(200, done);
      });
      it('should return 200 when adding new attribute to entity', function(done) {
        return api.post("" + apiVersion + "/entity/" + newEntityId + "/attribute").send({
          name: attributeName
        }).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          assert.isNumber(response.payload.id);
          newAttributeId = response.payload.id;
          return done();
        });
      });
      it('should return 200 when voting entity attribute', function(done) {
        return api.post("" + apiVersion + "/entity/" + newEntityId + "/attribute/" + newAttributeId + "/vote").send({
          tone: "positive"
        }).expect(200).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          assert.isNotNull(response.payload.upVote);
          assert.isNotNull(response.payload.downVote);
          return done();
        });
      });
      it('should return 200 when searching for entity', function(done) {
        return api.get("" + apiVersion + "/entity/search?q=" + entityName).expect(200).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          response.payload.should.have.length.above(0);
          return done();
        });
      });
      it('should return 200 when adding data', function(done) {
        return api.post("" + apiVersion + "/entity/" + newEntityId + "/data").send({
          dataType: 'text',
          name: 'Random',
          value: 'Hello World',
          selector: '',
          srcUrl: 'http://random.org'
        }).expect(201).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          response.success.should.equal(true);
          response.payload.should.have.id;
          response.payload.should.have.property('name', 'Random');
          response.payload.should.have.property('value', 'Hello World');
          response.payload.should.have.property('srcUrl', 'http://random.org');
          response.payload.should.have.property('selector', '');
          newDataId = response.payload.id;
          return done();
        });
      });
      return it('should return 200 when searching with #attribute', function(done) {
        return api.get(("" + apiVersion + "/search?q=") + encodeURIComponent("" + entityName + " #" + attributeName)).expect(200).end(function(err, res) {
          var response;
          response = JSON.parse(res.text);
          response.payload.should.have.length.above(0);
          return done();
        });
      });
    });
  });

}).call(this);

supertest = require('supertest')

chai = require('chai')
should = chai.should()
assert = chai.assert

app = require('../app').app

api = supertest(app)
apiVersion = app.version

describe 'Entity', () ->
    newEntityId = null
    newAttributeId = null

    it 'should return 404 when entity does not exist', (done) ->
        api.get("#{apiVersion}/entity/xyz")
            .expect(400)
            .expect({error:"Missing param id"}, done)

    it 'should return 201 when adding new entity', (done) ->
        api.post("#{apiVersion}/entity/")
            .send(name: "TEST_Mocha")
            .end (err, res) ->
                response = JSON.parse(res.text)
                assert.isNumber response.id
                newEntityId = response.id
                done()

    it 'should return 200 when getting existing entity', (done) ->
        api.get("#{apiVersion}/entity/#{newEntityId}")
            .expect(200, done)

    it 'should return 200 when updating existing entity', (done) ->
        api.put("#{apiVersion}/entity/#{newEntityId}")
            .send({name: "TEST_Attribute", version: 1})
            .end (err, res) ->
                response = JSON.parse(res.text)
                assert.equal response.version, 2
                done()

    it 'should return 200 when adding new attribute to entity', (done) ->
        api.post("#{apiVersion}/entity/#{newEntityId}/attribute")
            .send(name: "TEST_Attribute")
            .end (err, res) ->
                response = JSON.parse(res.text)
                assert.isNumber response.id
                newAttributeId = response.id
                done()

    it 'should return 200 when getting entity attribute', (done) ->
        api.get("#{apiVersion}/entity/#{newEntityId}/attribute")
            .end (err, res) ->
                response = JSON.parse(res.text)
                assert.isNotNull response
                done()

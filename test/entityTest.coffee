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
    entityName = "TEST_mocha"
    attributeName = "TEST_attr"

    it 'should return 400 when entity does not exist', (done) ->
        api.get("#{apiVersion}/entity/xyz")
            .expect(400)
            .expect({error:"Missing param id"}, done)

    it 'should return 201 when adding new entity', (done) ->
        api.post("#{apiVersion}/entity/")
            .send(name: entityName)
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
            .send({name: entityName + "1", version: 1})
            .end (err, res) ->
                response = JSON.parse(res.text)
                assert.equal response.version, 2
                done()

    it 'should return 200 when adding new attribute to entity', (done) ->
        api.post("#{apiVersion}/entity/#{newEntityId}/attribute")
            .send(name: attributeName)
            .end (err, res) ->
                response = JSON.parse(res.text)
                assert.isNumber response.id
                newAttributeId = response.id
                done()

    it 'should return 200 when voting entity attribute', (done) ->
        api.post("#{apiVersion}/entity/#{newEntityId}/attribute/#{newAttributeId}/vote")
            .send(tone: "positive")
            .expect(200)
            .end (err, res) ->
                response = JSON.parse(res.text)
                assert.isNotNull response.upVote
                assert.isNotNull response.downVote
                done()

    it 'should return 200 when searching for entity with other', (done) ->
        api.get("#{apiVersion}/entity/search?q=__global__ with #{attributeName} via _ATTRIBUTE")
            .expect(200)
            .end (err, res) ->
                response = JSON.parse(res.text)
                response.should.have.length.above 0
                done()

supertest  = require('supertest')

chai       = require('chai')
should     = chai.should()
assert     = chai.assert

app        = require('../app').app

api        = supertest(app)
apiVersion = app.version

describe 'Entity', () ->
    newEntityId    = null
    newAttributeId = null
    newDataId      = null
    entityName     = "TEST_mocha"
    attributeName  = "TEST_attr"
    dataName       = "TEST_data"

    it 'should return 400 when entity does not exist', (done) ->
        api.get("#{apiVersion}/entity/xyz")
            .expect(400, done)

    it 'should return 201 when adding new entity', (done) ->
        api.post("#{apiVersion}/entity/")
            .send(name: entityName)
            .end (err, res) ->
                response = JSON.parse(res.text)

                response.payload.should.have.property 'id'
                response.success.should.equal true
                newEntityId = response.payload.id

                done()

    it 'should return 200 when getting existing entity', (done) ->
        api.get("#{apiVersion}/entity/#{newEntityId}")
            .expect(200, done)

    it 'should return 200 when updating existing entity', (done) ->
        api.put("#{apiVersion}/entity/#{newEntityId}")
            .send({name: entityName + "1", version: 1})
            .end (err, res) ->
                response = JSON.parse(res.text)
                assert.equal response.payload.version, 1
                done()

    it 'should return 200 when adding new attribute to entity', (done) ->
        api.post("#{apiVersion}/entity/#{newEntityId}/attribute")
            .send(name: attributeName)
            .end (err, res) ->
                response = JSON.parse(res.text)
                assert.isNumber response.payload.id
                newAttributeId = response.payload.id
                done()

    it 'should return 200 when voting entity attribute', (done) ->
        api.post("#{apiVersion}/entity/#{newEntityId}/attribute/#{newAttributeId}/vote")
            .send(tone: "positive")
            .expect(200)
            .end (err, res) ->
                response = JSON.parse(res.text)
                assert.isNotNull response.payload.upVote
                assert.isNotNull response.payload.downVote
                done()

    it 'should return 200 when searching for entity', (done) ->
        api.get("#{apiVersion}/entity/search?q=#{entityName}")
            .expect(200)
            .end (err, res) ->
                response = JSON.parse(res.text)
                response.payload.should.have.length.above 0
                done()

    it 'should return 200 when adding data', (done) ->
        api.post("#{apiVersion}/entity/#{newEntityId}/data")
            .send({
                dataType: 'text'
                name: 'Random'
                value: 'Hello World'
                selector: ''
                srcUrl: 'http://random.org'
            })
            .expect(201)
            .end (err, res) ->
                response = JSON.parse res.text
                response.success.should.equal true
                response.payload.should.have.id
                response.payload.should.have.property 'name', 'Random'
                response.payload.should.have.property 'value', 'Hello World'
                response.payload.should.have.property 'srcUrl', 'http://random.org'
                response.payload.should.have.property 'selector', ''
                newDataId = response.payload.id
                done()
    it 'should return 200 when searching with #attribute', (done) ->
        api.get("#{apiVersion}/search?q="+encodeURIComponent("#{entityName} ##{attributeName}"))
            .expect(200)
            .end (err, res) ->
                response = JSON.parse res.text
                response.payload.should.have.length.above 0
                done()
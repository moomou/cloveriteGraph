supertest  = require 'supertest'

chai       = require 'chai'
assert     = chai.assert
should     = chai.should()

app        = require('../app').app

api        = supertest(app)
apiVersion = app.version

describe 'Entity', () ->
    newEntityId     = null
    newAttributeId  = null
    newDataId       = null
    userToken       = null
    username        = null
    privateEntityId = null

    entityName      = "TEST_mocha"
    attributeName   = "TEST_attr"
    dataName        = "TEST_data"

    describe 'with user', () ->
        before (done) ->
            api.post("#{apiVersion}/user")
                .set("x-access-token", "superman")
                .send({
                    username: "TEST_entityTestUser"
                    email: "entityTestUser@cloverite.com"
                })
                .end (err, res) ->
                    response  = JSON.parse res.text
                    userToken = response.payload.accessToken
                    username  = response.payload.username
                    done()

        it 'can create private data', (done) ->
            api.post("#{apiVersion}/entity/")
                .set("x-access-token", userToken)
                .send({
                    name    : 'random'
                    private : true
                })
                .end (err, res) ->
                    response = JSON.parse res.text

                    response.payload.should.have.property 'id'
                    response.payload.should.have.property 'private', true
                    response.payload.contributors.should.eql [username]
                    response.success.should.equal true

                    privateEntityId = response.payload.id
                    done()

        it 'private entity is accessible.', (done) ->
            api.get("#{apiVersion}/entity/#{privateEntityId}")
                .set("x-access-token", userToken)
                .expect(200, done)

        it 'private entity is hidden from others.', (done) ->
            api.get("#{apiVersion}/entity/#{privateEntityId}")
                .expect(401, done)

    describe 'with guest', () ->
        it 'should return 400 when entity does not exist', (done) ->
            api.get("#{apiVersion}/entity/xyz")
                .expect(400, done)

        it 'should return 201 when adding new entity', (done) ->
            api.post("#{apiVersion}/entity/")
                .send(name: entityName)
                .end (err, res) ->
                    response = JSON.parse(res.text)

                    response.payload.should.have.property 'id'
                    response.payload.should.have.property 'imgURL'
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

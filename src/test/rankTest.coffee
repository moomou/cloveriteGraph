supertest = require('supertest')

chai   = require('chai')
should = chai.should()
assert = chai.assert
app    = require('../app').app

api        = supertest(app)
apiVersion = app.version

describe 'Rank', () ->
    entityIds = []
    rankId    = null
    userToken = null
    username  = null
    userId    = null

    # Populating entity in db
    before (done) ->
        randomId = '#'+(Math.random()*0xFFFFFF<<0).toString(16)

        api.post("#{apiVersion}/entity/")
            .send(name: randomId)
            .end (err, res) ->
                response = JSON.parse(res.text)
                entityIds.push response.payload.id
                done()

    # Populating entity 2 in db
    before (done) ->
        randomId = '#'+(Math.random()*0xFFFFFF<<0).toString(16)

        api.post("#{apiVersion}/entity/")
            .send(name: randomId)
            .end (err, res) ->
                response = JSON.parse(res.text)
                entityIds.push response.payload.id
                done()

    # Populating user in db
    before (done) ->
        api.post("#{apiVersion}/user")
            .set("x-access-token", "superman")
            .send({
                username: "TEST_rankTestUser"
                email: "rankTestUser@cloverite.com"
            })
            .end (err, res) ->
                response  = JSON.parse res.text
                userToken = response.payload.accessToken
                username  = response.payload.username
                userId    = response.payload.id
                done()

    it 'should return 201 when creating new ranking', (done) ->
        api.post("#{apiVersion}/user/#{userId}/ranking")
            .send({name: "TEST_ranking", ranks: entityIds})
            .set('x-access-token', userToken)
            .expect(201)
            .end (err, res) ->
                response = JSON.parse(res.text)

                response.payload.should.have.id
                response.payload.ranks.should.eql entityIds
                response.payload.contributors.should.eql [username]

                done()

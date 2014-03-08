supertest = require('supertest')

chai   = require('chai')
should = chai.should()
assert = chai.assert

app = require('../app').app

api = supertest(app)
apiVersion = app.version
randomId = '#'+(Math.random()*0xFFFFFF<<0).toString(16)

describe 'User', () ->

    it 'creation should return 201 when creating user with privileged token', (done) ->
        api.post("#{apiVersion}/user")
            .set("x-access-token", "superman")
            .send({
                username: "TEST_#{randomId}"
                email: "#{randomId}@me.com"
            })
            .expect(201)
            .end (err, res) ->
                response = JSON.parse res.text

                assert.isNumber response.payload.id
                assert.isString response.payload.accessToken
                response.payload.should.have.property 'username', "TEST_#{randomId}"

                done()

    it 'creation should return 403 when creating user with bad token', (done) ->
        api.post("#{apiVersion}/user")
            .set("x-access-token", "wonder woman")
            .send({
                username: "TEST_#{randomId}"
                email: "#{randomId}@me.com"
            })
            .expect(403, done)

    it 'creation should return 400 when creating user incorrect info', (done) ->
        api.post("#{apiVersion}/user")
            .set("x-access-token", "superman")
            .send({
                username: "TEST_#{randomId}"
            })
            .expect(400, done)

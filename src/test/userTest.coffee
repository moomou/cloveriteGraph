supertest = require('supertest')

chai   = require('chai')
should = chai.should()
assert = chai.assert

app        = require('../app').app
api        = supertest(app)
apiVersion = app.version
randomId   = '#'+(Math.random()*0xFFFFFF<<0).toString(16)

describe 'User', () ->
    describe 'creation', () ->
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

    describe 'detail', () ->
        username  = null
        userId    = null
        userToken = null

        othername  = null
        otherId    = null
        otherToken = null

        publicEntityId  = null
        privateEntityId = null

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
                    userId    = response.payload.id
                    done()

        before (done) ->
            api.post("#{apiVersion}/user")
                .set("x-access-token", "superman")
                .send({
                    username: "TEST_entityTestOther"
                    email: "entityTestOther@cloverite.com"
                })
                .end (err, res) ->
                    response   = JSON.parse res.text
                    othername  = response.payload.username
                    otherId    = response.payload.id
                    otherToken = response.payload.accessToken
                    done()

        before (done) ->
            api.post("#{apiVersion}/entity/")
                .set("x-access-token", otherToken)
                .send({
                    name    : 'private'
                    private : true
                })
                .end (err, res) ->
                    response = JSON.parse res.text
                    privateEntityId = response.payload.id
                    done()

        before (done) ->
            api.post("#{apiVersion}/entity/")
                .set("x-access-token", otherToken)
                .send({
                    name    : 'public'
                })
                .end (err, res) ->
                    response = JSON.parse res.text
                    response.payload.should.have.property 'id'
                    publicEntityId = response.payload.id
                    done()

        it 'should return 200 with private info when accessing', (done) ->
            api.get("#{apiVersion}/user/#{otherId}")
                .set("x-access-token", otherToken)
                .end (err, res) ->
                    response = JSON.parse res.text
                    response.success.should.equal true
                    done()

        it 'should only see public created when accessing other user', (done) ->
            api.get("#{apiVersion}/user/#{otherId}/created")
                .set("x-access-token", userToken)
                .end (err, res) ->
                    response = JSON.parse res.text
                    response.success.should.equal true

                    console.log response
                    returnedIds = response.payload.map (obj) -> obj.id
                    returnedIds.should.eql [publicEntityId]

                    done()

        it 'should see both private and public created when accessing self', (done) ->
            api.get("#{apiVersion}/user/#{otherId}/created")
                .set("x-access-token", otherToken)
                .end (err, res) ->
                    response = JSON.parse res.text
                    response.success.should.equal true

                    console.log otherToken
                    returnedIds = response.payload.map (obj) -> obj.id
                    returnedIds.should.eql [privateEntityId, publicEntityId]
                    done()

        it 'should allow access to private info if shared', (done) ->
            done()

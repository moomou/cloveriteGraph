supertest = require('supertest')

chai = require('chai')
should = chai.should()
assert = chai.assert

app = require('../app').app

api = supertest(app)
apiVersion = app.version

userId = 53
accessToken = "user_d06dbc5cf2449cec33ff2aad1c4c9632"
ranks = [18, 19, 20]

describe 'Rank', () ->
    rankId = null
    it 'should return 201 when creating new rank', (done) ->
        api.post("#{apiVersion}/user/#{userId}/ranking")
            .send({name: "TEST_ranking", ranks: ranks})
            .set('x-access-token', accessToken)
            .expect(201)
            .end (err, res) ->
                console.log res.text
                response = JSON.parse(res.text)
                console.log response
                done()

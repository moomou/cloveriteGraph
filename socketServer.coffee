socketio = require('socket.io')

redis = require('./models/setup').db.redis

getFeed = (accessToken, feedType, cb) ->
    # Retrieve latest request feed
    await redis.get(accessToken, defer(err, neoUserId))
    return cb true, null if err

    requestFeedId = "user:#{neoUserId}:#{feedType}"

    await redis.lrange requestFeedId, 0, -1, defer(err, feeds)

    return cb true, null if err
    return cb null, JSON.stringify(feeds)

addToFeed = (accessToken, receiver, newFeed, feedType, cb) ->
    await redis.get(accessToken, defer(err, neoUserId))

    return cb true, null if err
    return cb true, null if not neoUserId

    requestFeedId = "user:#{neoUserId}:#{feedType}"

    redis.lpush requestFeedId,
        JSON.stringify(newFeed),
        (err, result) ->

# TODO Lacking authentication
module.exports = class IOServer
    instance = null
    constructor: (server) ->
        if instance
            return instance
        else
            io = socketio.listen(server)

            io.sockets.on 'connection', (socket) ->

                socket.emit 'ack', {}

                socket.on 'request feed', (data) ->
                    await getFeed data.accessToken,
                        "requestFeed",
                        defer(err, requestFeeds)
                    socket.emit 'request feed', JSON.stringify requestFeeds

                socket.on 'post request feed', (data) ->
                    receiver = data.recv
                    requestFeed = RequestFeed.fillMetaData(
                        RequestFeed.deserialize data.requestFeed)

                    accessToken = data.accessToken
                    addToFeed accessToken, receiver, requestFeed, "requestFeed", ->

                socket.on 'recommendation feed', (data) ->
                    await getFeed data.accessToken,
                        "recommendationFeed",
                        defer(err, recommendationFeeds)
                    socket.emit 'request feed', JSON.stringify recommendationFeeds

                socket.on 'post recommendation feed', (data) ->
                    receiver = data.recv
                    requestFeed = RecommendationFeed.fillMetaData(
                        RecommendationFeed.deserialize data.requestFeed)

                    accessToken = data.accessToken
                    addToFeed accessToken, receiver, requestFeed, "recommendationFeed", ->

            instance = io

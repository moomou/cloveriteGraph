express = require('express')
useragent = require('express-useragent')
require('express-namespace')

routes = require('./routes')

app = express()

app.set('port', process.env.PORT || 3000)
app.use(express.logger('dev'))
app.use(express.query())
app.use(express.bodyParser())
app.use(express.methodOverride())
app.use(useragent.express())
app.use(app.router)

#development only
if 'development' == app.get('env')
    app.use(express.errorHandler())

app.version = '/v0'

addCORSHeaders = (req, res, next) ->
    res.header('Access-Control-Allow-Origin', req.headers.origin || req.headers.host)
    res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    res.header('Access-Control-Allow-Headers', "DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Referer,x-access-token")
    res.header('Access-Control-Allow-Credentials', 'true')
    next()

app.namespace(app.version, () ->

# Adding CORS
    app.get('/*', addCORSHeaders)
    app.post('/*', addCORSHeaders)
    app.put('/*', addCORSHeaders)
    app.delete('/*', addCORSHeaders)

# Search Handler for multiple resource
    app.get('/search/:type?', routes.search.searchHandler)

# User API
    app.post('/user/', routes.user.createUser)
    app.get('/user/:id', routes.user.getSelf)

    # External Channels
    #app.get('/user/:id/discussion', routes.user.getDiscussion)
    app.get('/user/:id/request', routes.user.getRequest)
    app.post('/user/:id/request', routes.user.sendRequest)

    app.get('/user/:id/recommendation', routes.user.getRecommendation)
    app.post('/user/:id/recommendation', routes.user.sendRecommendation)
    
        # Internal Channels 
    app.get('/user/:id/created', routes.user.getCreated)
    app.get('/user/:id/voted', routes.user.getVoted)
    app.get('/user/:id/commented', routes.user.getCommented)
    app.get('/user/:id/ranked', routes.user.getRanked)

    # Ranking API
    app.get '/user/:id/ranking/:rankingId', routes.ranking.show
    app.post '/user/:id/ranking', routes.ranking.create
    app.put '/user/:id/ranking/:rankingId', routes.ranking.edit
    app.delete '/user/:id/ranking/:rankingId', routes.ranking.delete

    # Sharing Ranking
    app.get('/ranking/share/:shareToken', routes.ranking.shareView)

# Entity Method
    app.get('/entity/search', routes.entity.search)

    app.post('/entity', routes.entity.create)
    app.get('/entity/:id', routes.entity.show)
    app.put('/entity/:id', routes.entity.edit)
    app.del('/entity/:id', routes.entity.del)

    # Entity User Method
    app.get('/entity/:id/users', routes.entity.showUsers)

    # Entity Attribute Method
    app.post('/entity/:id/attribute', routes.entity.addAttribute)
    app.get('/entity/:id/attribute', routes.entity.listAttribute)
    app.get('/entity/:eId/attribute/:aId', routes.entity.getAttribute)
    app.put('/entity/:eId/attribute/:aId', routes.entity.updateAttributeLink)
    app.del('/entity/:eId/attribute/:aId', routes.entity.delAttribute)

    app.post('/entity/:eId/attribute/:aId/vote', routes.entity.voteAttribute)

    # Entity Comment Method
    app.post('/entity/:id/comment', routes.entity.addComment)
    app.get('/entity/:id/comment', routes.entity.listComment)
    app.del('/entity/:id/comment', routes.entity.delComment)

    # Entity Relation
    ## return entity connected by relation, can be prefix or exact match
    app.get('/entity/:id/:relation', routes.entity.listRelation)

    ## returns all relationship
    app.get('/entity/:id/relation', routes.entity.listRelation)

    app.post('/entity/:srcId/relation/entity/:dstId', routes.entity.linkEntity)
    app.del('/entity/:srcId/relation/entity/:dstId', routes.entity.unlinkEntity)

# Attribute
    app.get('/attribute/search', routes.attribute.search)

    app.post('/attribute', routes.attribute.create)
    app.get('/attribute/:id', routes.attribute.show)
    app.put('/attribute/:id', routes.attribute.edit)
    app.del('/attribute/:id', routes.attribute.del)

    # Attribute Entity
    ## GET - get all entity who have this attribute
    app.get('/attribute/:id/entity', routes.attribute.listEntity)
)

exports.app = app

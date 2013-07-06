require('source-map-support').install()

express = require('express')
routes = require('./routes')
http = require('http')
useragent = require('express-useragent')
path = require('path')

app = express()

app.set('port', process.env.PORT || 3000)
app.use(express.logger('dev'))
app.use(express.query())
app.use(express.bodyParser())
app.use(express.methodOverride())
app.use(useragent.express())

#app.use(app.router)

#development only
if ('development' == app.get('env'))
  app.use(express.errorHandler())

  ##Routes
#Global Function  
#app.get('/search', routes.search.searchHandler)
app.get('/search/:type?', routes.search.searchHandler)

#Entity
app.post('/entity', routes.entity.create)
app.get('/entity/search', routes.entity.search)
app.get('/entity/:id', routes.entity.show)
app.put('/entity/:id', routes.entity.edit)
app.del('/entity/:id', routes.entity.del)

#Entity->attribute
app.post('/entity/:id/attribute', routes.entity.addAttribute)

app.get('/entity/:id/attribute', routes.entity.listAttribute)
app.get('/entity/:eId/attribute/:aId', routes.entity.getAttribute)
app.put('/entity/:eId/attribute/:aId', routes.entity.updateAttributeLink)
app.del('/entity/:eId/attribute/:aId', routes.entity.delAttribute)
app.post('/entity/:eId/attribute/:aId/vote', routes.entity.voteAttribute)

#Entity->comment
###
app.post('/entity/:id/comment', routes.entity.addComment)
app.post('/entity/:eId/attribute/:aId/comment', routes.entity.addComment)

app.get('/entity/:id/comment', routes.entity.listComment)
app.get('/entity/:eId/attribute/:aId/comment', routes.entity.listComment)

app.del('/entity/:id/comment', routes.entity.delComment)
app.del('/entity/:eId/attribute/:aId/comment', routes.entity.delComment)
###

#Entity->relation
app.get('/entity/:id/:relation', routes.entity.listRelation) #return entity connected by relation, can be prefix or exact match
app.get('/entity/:id/relation', routes.entity.listRelation)  #returns all relationship

app.post('/entity/:srcId/relation/entity/:dstId', routes.entity.linkEntity)
app.del('/entity/:srcId/relation/entity/:dstId', routes.entity.unlinkEntity)

#Attribute
app.post('/attribute', routes.attribute.create)
app.get('/attribute/search', routes.attribute.search)
app.get('/attribute/:id', routes.attribute.show)
app.put('/attribute/:id', routes.attribute.edit)
app.del('/attribute/:id', routes.attribute.del)

#Attribute->entity
app.get('/attribute/:id/entity', routes.attribute.listEntity)

http.createServer(app).listen(app.get('port'), ->
    console.log('Express server listening on port ' + app.get('port')))

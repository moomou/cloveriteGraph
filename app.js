// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var app, express, http, routes, useragent;



  express = require('express');

  http = require('http');

  useragent = require('express-useragent');

  routes = require('./routes');

  app = express();

  app.set('port', process.env.PORT || 3000);

  app.use(express.logger('dev'));

  app.use(express.query());

  app.use(express.bodyParser());

  app.use(express.methodOverride());

  app.use(useragent.express());

  app.use(app.router);

  if ('development' === app.get('env')) {
    app.use(express.errorHandler());
  }


  /*
  # Routes
  */

  app.get('/search/:type?', routes.search.searchHandler);


  /*
  # Entity Method
  # POST
  # GET
  # DEL
  # PUT
  */

  app.get('/entity/search', routes.entity.search);

  app.post('/entity', routes.entity.create);

  app.get('/entity/:id', routes.entity.show);

  app.put('/entity/:id', routes.entity.edit);

  app.del('/entity/:id', routes.entity.del);


  /*
  # Entity Attribute  Method
  # POST - add attribute
  # GET - get all attribute
  # DEL - delete an attribute
  # PUT - update Attribute
  */

  app.post('/entity/:id/attribute', routes.entity.addAttribute);

  app.get('/entity/:id/attribute', routes.entity.listAttribute);

  app.get('/entity/:eId/attribute/:aId', routes.entity.getAttribute);

  app.put('/entity/:eId/attribute/:aId', routes.entity.updateAttributeLink);

  app.del('/entity/:eId/attribute/:aId', routes.entity.delAttribute);

  app.post('/entity/:eId/attribute/:aId/vote', routes.entity.voteAttribute);


  /* TODO
  # Entity Comment Method
  # POST - add comment
  # GET - get all comment
  # DEL - delete a comment
  app.post('/entity/:id/comment', routes.entity.addComment)
  app.get('/entity/:id/comment', routes.entity.listComment)
  app.del('/entity/:id/comment', routes.entity.delComment)
  */


  /*
  # Entity Relation
  # Entity Comment Method
  # GET - get relation
  # POST - add relation
  # DEL - delete a comment
  */

  app.get('/entity/:id/:relation', routes.entity.listRelation);

  app.get('/entity/:id/relation', routes.entity.listRelation);

  app.post('/entity/:srcId/relation/entity/:dstId', routes.entity.linkEntity);

  app.del('/entity/:srcId/relation/entity/:dstId', routes.entity.unlinkEntity);


  /*
  # Attribute
  # POST
  # GET
  # DEL
  # PUT
  */

  app.get('/attribute/search', routes.attribute.search);

  app.post('/attribute', routes.attribute.create);

  app.get('/attribute/:id', routes.attribute.show);

  app.put('/attribute/:id', routes.attribute.edit);

  app.del('/attribute/:id', routes.attribute.del);


  /*
  # Attribute Entity
  # GET - get all entity who have this attribute
  */

  app.get('/attribute/:id/entity', routes.attribute.listEntity);

  http.createServer(app).listen(app.get('port'), function() {
    return console.log('Express server listening on port ' + app.get('port'));
  });

}).call(this);

//# sourceMappingURL=app.map

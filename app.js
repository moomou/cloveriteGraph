/**
 * Module dependencies.
 */

var express = require('express')
  , routes = require('./routes')
  , http = require('http')
  , path = require('path');

var app = express();

// all environments
app.set('port', process.env.PORT || 3000);
app.use(express.logger('dev'));
app.use(express.query());
app.use(express.bodyParser());
app.use(express.methodOverride());
//app.use(app.router);

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

/* Routes
 * ******
 */

//Entity
app.post('/entity', routes.entity.create);
app.get('/entity', routes.entity.search);
app.get('/entity/:id', routes.entity.show);
app.put('/entity/:id', routes.entity.edit);
app.del('/entity/:id', routes.entity.del);

app.post('/entity/:id/attribute', routes.entity.addAttribute);
app.get('/entity/:id/attribute', routes.entity.listAttribute);
app.del('/entity/:eId/attribute/:aId', routes.entity.delAttribute);

app.post('/entity/:id/attribute/:aId/vote', routes.entity.voteAttribute);

//app.get('/entity/:id/link/:relation', routes.entity.show);

//Attribute
app.post('/attribute', routes.attribute.create);
app.get('/attribute', routes.attribute.search);
app.get('/attribute/:id', routes.attribute.show);
app.put('/attribute/:id', routes.attribute.edit);
app.del('/attribute/:id', routes.attribute.del);

app.get('/attribute/:id/entity', routes.attribute.listEntity);

// END

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});

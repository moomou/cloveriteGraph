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

// Routes
//Entity
app.post('/entity', routes.entity.create);
app.get('/entity/:id', routes.entity.show);
app.put('/entity/:id', routes.entity.edit);
app.del('/entity/:id', routes.entity.del);

app.get('/entity/:id/:relation', routes.entity.show);

// END

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});

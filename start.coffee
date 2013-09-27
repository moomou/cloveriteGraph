http = require('http')

app = require('./app').app

server = http.createServer(app)
server.listen(app.get('port'), -> console.log('Express server listening on port ' + app.get('port')))

# Create IO Server
# ioServer = require('./socketServer')(server)

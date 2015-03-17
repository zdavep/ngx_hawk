var restify = require('restify');

function helloV1(req, res, next) {
  res.send('Hello ' + req.params.name);
  next();
}

function helloV2(req, res, next) {
  res.send({code: 'Success', message: 'Hello, ' + req.params.name});
  next();
}

var path = '/hello/api/greeting/:name';

var server = restify.createServer({name:'hello-service'});
server.get({path: path, version: ['2.0.0', '2.1.1']}, helloV2);
server.get({path: path, version: '1.0.0'}, helloV1);

server.listen(8080, function() {
  console.log('%s listening at %s', server.name, server.url);
});


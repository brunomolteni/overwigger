var express = require('express')
  , Primus = require('primus')
  , http = require('http')
  , https = require('https')
  , fs = require('fs')
  , path = require('path')
  , app = express()
  , server = http.createServer(app);

  var SILENT = true;

// ------------------------- UTILS ----------------------------------

function log(){
  SILENT || console.log.apply(this,arguments);
}

function getNetworkIP(callback) {
  var socket = net.createConnection(80, 'www.google.com');
  socket.on('connect', function() {
    callback(undefined, socket.address().address);
    socket.end();
  });
  socket.on('error', function(e) {
    callback(e, 'error');
  });
}

function toBytesInt32 (num) {
    arr = new ArrayBuffer(4);
    view = new DataView(arr);
    view.setUint32(0, num, false);
    return arr;
}

Buffer.prototype.readBytes = function () {
  var messagetxt = ''
  // Convert bytes to string
  for(var i = 0; i < this.length; i++) {
    messagetxt += String.fromCharCode(this[i]);
  }
  return messagetxt;
};
String.prototype.getBytes = function () {
  var textBuff = new Buffer(this.toString());
  var lengthBuff = new Buffer(toBytesInt32(textBuff.length));
  var resultBuff = Buffer.concat([lengthBuff,textBuff]);

  return resultBuff;
};

function sendToBitwig(data){
  if(isBitwigConnected) bitwig.write( JSON.stringify(data).getBytes() );
}

function sendToBrowser(data){
  if(primus && primus.write) primus.write(data);
}

function connectToBitwig(){
  bitwig = reconnect();

  bitwig.on('connect', function() {
    log(' -------- Bitwig connected ---------');
    isBitwigConnected = true;
  });

  bitwig.on('data', function(data) {
    parsedData = data.readBytes();
    log('got data from Bitwig: \n', parsedData, '\n');
    sendToBrowser(parsedData);
  });

  bitwig.on('close', function(error) {
    log('connection closed');
    isBitwigConnected = false;
    setTimeout( connectToBitwig, 2000 )
  });

  bitwig.on('error', function (err) {
      log(err);
  });
}

// ------------------------- SERVER TO BITWIG ----------------------------------

var reconnect = net.connect.bind(this,{port: 42000, localAddress: '127.0.0.1', localPort: 50000});
var bitwig;
isBitwigConnected = false;
connectToBitwig();

// ------------------------- SERVER TO BROWSER ---------------------------------

var primus = new Primus(server, {transformer: 'websockets'});
var browser;

primus.on('connection', function (spark) {
  browser = spark;
  sendToBitwig({init: true});

  spark.on('data', function message(data) {
    log('got data from Browser: \n',data, '\n');
    if(data.ip)
      getNetworkIP( function (error, ip) {
            spark.write(JSON.stringify({ip: ip}));
            console.log('ip');
            if (error) {
                log("Couldn't get this machine ip, got error:", error);
            }
        })
    else sendToBitwig(data);
  });
});

primus.save(path.join(__dirname +'/src/js/primus.js'));

// ------------------------- START SERVER ---------------------------------

app.use('/',express.static('src'));

app.get('/primus/primus', function (req, res) {
  res.send(primus.library());
});

// start server
server.listen(8888,'0.0.0.0');

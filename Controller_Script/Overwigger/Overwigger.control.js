loadAPI(5);
load('es5-shim.min.js');
load('json3.min.js');

// Remove this if you want to be able to use deprecated methods without causing script to stop.
// This is useful during development.
host.setShouldFailOnDeprecatedUse(true);

host.defineController("Brumo", "Overwigger", "0.1", "92eacc16-33df-44a9-8602-1e818f68ddff", "Brumo");

var clientConn;
var clientIsConnected = false;
var app;
var track1;
var device1;
var macros = [];
var tracks = [];
var arrayOf8 = createArray(8);
var arrayOf4 = createArray(4);

var SILENT = false;

//
// Callbacks
//

function init()
{
  log( "-------- INIT ---------");
  app = host.createApplication();
  masterTrack = host.createMasterTrack(0);
  cursorTrack = host.createCursorTrack(4, 8);
  trackBank = host.createMainTrackBank(8, 4, 4);
	trackBank.followCursorTrack(cursorTrack);


  // -------------------------------------------------------------------------------------------------
  // ----------------------------------------- Set state: ---------------------------------------
  // -------------------------------------------------------------------------------------------------

  arrayOf8.forEach( function(i1){
    var channel = trackBank.getItemAt(i1);
    var device = channel.createCursorDevice("Primary");
    var chain = device.deviceChain();
    var deviceMacros = device.createCursorRemoteControlsPage(8);
    var macros = arrayOf4.map( function(i2){
      var macro = deviceMacros.getParameter(i2);
      macro.setIndication(true);
      return {macro: macro, moving: false};
    })

    tracks.push({track: channel, macros: macros, device: device, controls: deviceMacros});
    // channel.selectInMixer();
    // device.selectFirstInChannel( device.channel() );
  });

  // -------------------------------------------------------------------------------------------------
  // ----------------------------------------- Set Listeners: ---------------------------------------
  // -------------------------------------------------------------------------------------------------

  function setupListeners() {
    tracks.forEach( function(el, i){

      // el.track.addNoteObserver( function(noteOn, key, velocity){
      //   sendToBrowser({track:i, note: {noteOn: noteOn, key: key, velocity: velocity} });
      // });

      el.track.name().addValueObserver( function(val){
        !!val && sendToBrowser({track: i, name: val });
      });

      el.track.color().addValueObserver( function(val){
         !!val && sendToBrowser({track: i, color: val });
      });

      el.macros.forEach( function(el,h,arr){
        el.macro.value().addValueObserver( function(val){
          !arr[h].moving && sendToBrowser({track: i, macro: h, value: val });
        });

        el.macro.name().addValueObserver( function(val){
          !!val && sendToBrowser({track: i, macro: h, name: val});
        });
      });

    });
  }

  setupListeners();

  // -------------------------------------------------------------------------------------------------
  // ----------------------------------------- Respond to Input: ---------------------------------------
  // -------------------------------------------------------------------------------------------------

  function respondToInput(data){

    // Re-assemble the Data from the incoming Byte Array:
    var dataString = bytesToString(data);
    var data = JSON3.parse( dataString );

    log("Client Data Incomming ----------------------------");
    log("data: " + dataString + "\n");

    if(typeof data.macro !== 'undefined'){
      if(data.value === 'release'){
        var macroValue = tracks[data.track].macros[data.macro].macro.value();
        tracks[data.track].macros[data.macro].moving = false;
        // sendToBrowser( {track: data.track , macro: data.macro, value: macroValue });
      }
      else {
        tracks[data.track].macros[data.macro].macro.value().set(data.value, 128);
        tracks[data.track].macros[data.macro].moving = true;
      }
    }

    if(data.init){
     sendInitialLayout();
     // setupListeners();
    }
  }

  // -------------------- INITIAL LAYOUT ----------------------

  function sendInitialLayout(){

    var macrosArray = [];

    // log(new host.HardwareControlType());

    var channels = tracks.map( function(el){
      // el.track.selectInMixer();
      // el.device.selectFirstInChannel( el.device.channel() );
      // el.controls.setHardwareLayout( "SLIDER", 8 );
      // el.device.selectInEditor();
      var name = el.track.name().get();
      var color = returnColor( el.track.color() );
      var macros = el.macros.map( function(el){
        return { name: el.macro.name().get(), value: el.macro.value().get() }
      });
      return {name: name , color: color, macros: macros };
    });
    // tracks[0].track.selectInMixer();

    var layout = {
      channels: channels
    };

    sendToBrowser(layout);
  }

  // -------------------------------------------------------------------------------------------------
  // ----------------------------------------- Set Connection: ---------------------------------------
  // -------------------------------------------------------------------------------------------------

  reSocket = host.createRemoteConnection("Overwigger", 42000);
  reSocket.setClientConnectCallback(function (cConn)
  {
    clientConn = cConn;
    clientIsConnected = true;
    log("Client connected");
    log(reSocket.getPort());

    // ----------------------- Set Callback for Incoming Data: ----------------
    clientConn.setReceiveCallback( respondToInput );

    // ------------------- Set Callback for Closing connection: ----------------
    clientConn.setDisconnectCallback(function (){
      clientIsConnected = false;
      log("Client disconnected");
    });
  });
}

function exit()
{
  log( "++++++++ EXIT +++++++++");
}


// -------------------------------------------------------------------------------------------------
// ----------------------------------------- UTILITIES: --------------------------------------------
// -------------------------------------------------------------------------------------------------


function returnColor(color){
  return {
    r: scaleColor( color.red() ),
    g: scaleColor( color.green() ),
    b: scaleColor( color.blue() ),
    a: scaleColor( color.alpha() )
  }
}

String.prototype.getBytes = function () {
  var bytes = [];
  for (var i = 0; i < this.length; ++i) {
    bytes.push(this.charCodeAt(i));
  }
  return bytes;
};

function bytesToString(data) {
  var clientData = "";
  for (var i=0; i<data.length; i++) {
    clientData += String.fromCharCode(data[i])
  }
  return clientData;
};

function scaleColor(unscaledNum) {
return Math.floor( (255 - 0) * (unscaledNum - 0) / (1 - 0) + 0);
}

function scaleRange(unscaledNum) {
return Math.floor( (127 - 0) * (unscaledNum - 0) / (1 - 0) + 0);
}

function sendToBrowser(data)
{
  if(clientIsConnected && clientConn){
    clientConn.send( JSON.stringify(data).getBytes() );
    log('Data sent to browser:');
    log(JSON.stringify(data) + "\n");
  }
}

function createArray(length){
  var array = []
  for (var i = 0; i < length; i++) {
    array[i] = i;
  }
  return array;
}

function log(msg){
  SILENT || println(msg);
}

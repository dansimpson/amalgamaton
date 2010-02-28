Function.prototype.bind = function(scope) {
  var _func = this;
  return function() {
    return _func.apply(scope, arguments);
  }
}

var Amalgamaton = {

  init: function(opts) {
    for(var k in opts) {
      this[k] = opts[k];
    }
    this.embed();
  },
  
  sock	: null,
  url		: null,
  
  connect	: function() {
    this.sock = new WebSocket(this.url);
    this.sock.onopen    = this.onConnect;
    this.sock.onmessage = this.onMessage.bind(this);
    this.sock.onclose   = this.onDisconnect;
  },
  
  onConnect: function(e) {
    document.getElementById("status").innerHTML = "Connected";
  },
  
  onMessage: function(e) {
    var obj = JSON.parse(e.data);
    switch(obj.action) {
      case "tick":
        this.play("tick");
        break;
      case "preload":
        this.add(obj.items);
      case "play":
        this.play(obj.items);
        break;
      default:
        break;
    }
  },
  
  onDisconnect: function(e) {
    document.getElementById("status").innerHTML = "Disconnected";
  },
  
  
  onProxyReady: function() {
    this.proxy = document.getElementById("proxy");
    this.connect();
    this.add({ id: "tick", url:"media/samples/tick.mp3" });
    this.add({ id: "1", url:"media/samples/club-dance-beat-005.mp3" });
    this.add({ id: "2", url:"media/samples/acoustic-noodling-02.mp3" });
    this.add({ id: "3", url:"media/samples/exotic-sarod-01.mp3" });
    this.add({ id: "4", url:"media/samples/edgy-rock-bass-06.mp3" });
    this.add({ id: "5", url:"media/samples/orchestra-strings-08.mp3" });
    this.add({ id: "6", url:"media/samples/upright-funk-bass-05.mp3" });
  },
  
  embed : function() {
    
    if(this.proxy) {
      return;
    }

    swfobject.embedSWF(
      "flash/amalgamaton.swf?" + Math.random().toString(),
      "proxy",
      "10",
      "10",
      "9",
      "flash/playerProductInstall.swf",
      {},
      {
        allowScriptAccess : "always",
        wmode             : "opaque",
        bgcolor           : "#ff0000"
      },
      {},
      function() {
      }
    );
  },
  
  add: function(sample) {
    this.proxy.add(sample.id, sample.url);
  },
  
  play: function(id) {
    this.proxy.play(id);
  }

};

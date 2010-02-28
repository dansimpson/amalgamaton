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
        this.addAll(obj.items);
      case "play":
        if(obj.items.constructor == Array) {
          this.playAll(obj.items);
        } else {
          this.play(obj.items);
        }
        break;
      case "stop":
        if(obj.items.constructor == Array) {
          this.stopAll(obj.items);
        } else {
          this.stop(obj.items);
        }
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
  
  addAll: function(samples) {
    for(var i = 0;i < samples.length;i++) {
      this.add(samples[i]);
    }
  },
  
  play: function(id) {
    this.proxy.play(id);
  },
  
  playAll: function(samples) {
    for(var i = 0;i < samples.length;i++) {
      this.play(samples[i]);
    }
  },
  
  stop: function(id) {
    this.proxy.stop(id);
  },

  stopAll: function(samples) {
    for(var i = 0;i < samples.length;i++) {
      this.stop(samples[i]);
    }
  }

};

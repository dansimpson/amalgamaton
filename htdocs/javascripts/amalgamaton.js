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
    this.sock.onopen    = this.onConnect.bind(this);
    this.sock.onmessage = this.onMessage.bind(this);
    this.sock.onclose   = this.onDisconnect;
  },
  
  onConnect: function(e) {
    document.getElementById("status").innerHTML = "Connected";
    this.send({action:"refresh"});
  },
  
  onMessage: function(e) {
    var obj = JSON.parse(e.data);
    switch(obj.action) {
      case "activate":
        if(this.grid) {
          this.grid.activate(obj.x,obj.y);
        }
        break;
      case "deactivate":
        if(this.grid) {
          this.grid.deactivate(obj.x,obj.y);
        }
        break;
      case "refresh":
        if(this.grid) {
          this.grid.refresh(obj.grid);
        }
        break;
      case "clear":
        if(this.grid) {
          this.grid.clear();
        }
        break;
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
  },
  
  subscribe: function(family) {
    this.send({action: "subscribe", family: family});
  },
  
  unsubscribe: function(family) {
    this.send({action: "unsubscribe", family: family});
  },
  
  send: function(obj) {
    this.sock.send(JSON.stringify(obj));
  },
  
  onGridEvent: function(x,y) {
    this.send({ action: "click", x: x, y: y });
  }

};


var Grid = function(opts) {
  for(var k in opts) {
    this[k] = opts[k];
  }
  
  if(!(this.width && this.height)) {
    throw "Grid requires width and height";
  }
  
  this.rows = [];
  for(var y = 0;y < this.height;y++) {
    this.rows[y] = [];
    for(var x = 0;x < this.width;x++) {
      this.rows[y][x] = { on: false };
    }
  }
};

Grid.prototype = {

  handler : null,
  rows    : null,

  get: function(x,y) {
    this.rows[y][x];
  },
  
  set: function(x,y,obj) {
    this.rows[y][x] = obj;
  },
  
  activate: function(x,y) {
    this.rows[y][x].addClass("on");
  },
  
  deactivate: function(x,y) {
    this.rows[y][x].removeClass("on");
  },
  
  clear: function() {
    for(var y = 0;y < this.height;y++) {
      for(var x = 0;x < this.width;x++) {
        this.deactivate(x,y);
      }
    }
  },
  
  refresh: function(grid) {
    for(var y = 0;y < this.height;y++) {
      for(var x = 0;x < this.width;x++) {
        if(grid[y][x]) {
          this.activate(x,y);
        } else {
          this.deactivate(x,y);
        }
      }
    }
  },
  
  
  render: function(el) {
    var grid = $("<table class=\"grid\"></table>");
    
    for(var y = 0;y < this.height;y++) {
      var tr = $("<tr></tr>");
      for(var x = 0;x < this.width;x++) {
        var td = $("<td></td>");
        
        var a = $("<a href=\"#\" rel=\"" + [y,x].join(",") + "\"></a>");
        a.bind("click", this.onClick.bind(this));
        
        this.set(x,y,a);
        
        td.append(a);
        tr.append(td);
      }
      grid.append(tr);
    }
    grid.appendTo(el);
  },
  
  notify: function(fn) {
    this.handler = fn;
  },
  
  onClick: function(e) {
    var coords = e.target.rel.split(",");
    var x = coords[1] * 1;
    var y = coords[0] * 1;
    this.handler(x,y);
  }
  
  

};
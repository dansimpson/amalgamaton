require 'rubygems'
require 'mq'
require 'json'
require 'pp'

require 'monome'

AMQP.start(:host => "192.168.0.2") do

  mq = MQ.new
  monome = Monome.new

  mq.queue("monome").bind(mq.topic("amalgamaton"), :key => "orchestra").subscribe do |msg|
    msg = JSON.parse(msg)
    action, x, y = msg['action'], msg['x'], msg['y']
    case msg['action']
    when "click"
      monome.toggle!(x, y)
    when "refresh"
      message = %({"action": "refresh", "grid": #{monome.grid.to_json}})
      puts message
      mq.topic("amalgamaton").publish(message, :key => "conductor")
    else
      puts "Received message #{msg}"
    end
  end
  
  monome.on_activate do |x, y|
    message = %({ "x": #{x}, "y": #{y}, "action": "activate" })
    mq.topic("amalgamaton").publish(message, :key => "conductor")
  end
  
  monome.on_deactivate do |x, y|
    message = %({ "x": #{x}, "y": #{y}, "action": "deactivate" })
    mq.topic("amalgamaton").publish(message, :key => "conductor")
  end
  
  monome.on_clear do
    message = %({"action": "clear"})
    mq.topic("amalgamaton").publish(message, :key => "conductor")
  end
  
  Thread.new do
    loop do
      monome.read!
    end
  end
  
end

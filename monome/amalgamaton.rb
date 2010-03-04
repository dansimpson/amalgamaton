require 'rubygems'
require 'mq'
require 'json'
require 'pp'
require 'monome'
require 'sequencer'

BPM = 240

samples = []

AMQP.start(:host => "192.168.0.2") do

  mq = MQ.new
  
  monome = Monome.new
  sequencer = Sequencer.new(8, monome)
  sequencer.samples = %w(
    techno-hat-1.mp3
    techno-ping.mp3
    techno-snare-1.mp3
    techno-snare-2.mp3
    techno-bass-1.mp3
  ).collect.with_index do |sample, i|
    { :id => i.to_s, :url => "media/samples/#{sample}" }
  end
  
  
  EM.add_periodic_timer(60.0 / BPM) do
    beat = sequencer.tick!
    play_commands = monome.grid.col(beat).collect.with_index do |play, i|
      i.to_s if play
    end.compact
    message = %({"action": "play", "items": #{play_commands.to_json}})
    puts message
    mq.topic("amalgamaton").publish(message, :key => "conductor")
  end
  
  mq.queue(rand.to_s).bind(mq.topic("amalgamaton"), :key => "orchestra").subscribe do |msg|
    msg = JSON.parse(msg)
    action, x, y = msg['action'], msg['x'], msg['y']
    case msg['action']
    when "click"
      monome.toggle!(x, y)
    when "refresh"
      monome.refresh
    when "clear"
      monome.clear!
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
  
  monome.on_refresh do
    message = %({"action": "refresh", "grid": #{monome.grid.to_json}})
    mq.topic("amalgamaton").publish(message, :key => "conductor")
    sequencer.preload
  end

  sequencer.on_preload do |samples|
    message = %({"action": "preload", "items": #{samples.to_json}})
    mq.topic("amalgamaton").publish(message, :key => "conductor")
  end
  
  Thread.new do
    loop do
      monome.read!
    end
  end
  
end

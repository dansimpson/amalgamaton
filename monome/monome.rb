require "rubygems"
require "monome_serial"
require "eventmachine"
require "amqp"
require "mq"

require "orchestra"

BEATS_PER_MINUTE = 120

mq = nil

EventMachine.run do
  
  AMQP.start(:host => "192.168.0.2")
  mq = MQ.new
  mq.topic("amalgamaton").publish("hey there!", :key => "test")
  
  
  orchestra = Orchestra.new(mq)

  Thread.new do
    loop do
      orchestra.conduct!
    end
  end

  EM.add_periodic_timer(60.0 / BEATS_PER_MINUTE) do
    orchestra.tick!
  end
  
end

require 'rubygems'
require 'mq'
require 'json'

AMQP.start(:host => "localhost") do

  @mq = MQ.new

  EM.add_periodic_timer(8) do
	@mq.topic('amalgamaton').publish(%({"action":"play","items":["1"]}))

	puts "Playing 1"
  end
  
  EM.add_periodic_timer(4) do
	@mq.topic('amalgamaton').publish(%({"action":"play","items":["2"]}))

	puts "Playing 1"
  end

end
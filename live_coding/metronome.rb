require 'rubygems'
require 'mq'
require 'json'

BEATS_PER_MINUTE = 120

AMQP.start(:host => "localhost") do

  @mq = MQ.new
  EM.add_periodic_timer(1) do
    @mq.topic('amalgamaton').publish(%({"action":"tick","offset":1}), :key => "conductor")
  end

end



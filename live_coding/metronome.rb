require 'rubygems'
require 'mq'
require 'json'

AMQP.start(:host => "localhost") do

  @mq = MQ.new

  EM.add_periodic_timer(0.5) do
    
    @tick = ((@tick || 0) + 1) % 8
    @mq.topic('amalgamaton').publish(%({"action":"tick","offset":#{@tick}}))

    puts "Tick #{@tick}"
  end

end



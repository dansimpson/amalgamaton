require 'rubygems'
require 'monome_serial'
require 'eventmachine'
require 'amqp'
require 'mq'

BEATS_PER_MINUTE = 120

mq = nil

EventMachine.run do
  
  AMQP.start(:host => '192.168.0.2')
  mq = MQ.new
  mq.topic("amalgamaton").publish("hey there!", :key => "test")
  
  
  class Orchestra

    def initialize(mq)
      @monome = MonomeSerial.detect_monome
      @grid = Hash.new
      @mq = mq
    end

    def keydown(x, y)
      message = "{'action':'keydown','x':#{x},'y':#{y}}"
      puts message
      @mq.topic("amalgamaton").publish(message)
    end

    def keyup(x, y)
      message = "{'action':'keyup','x':#{x},'y':#{y}}"
      puts message
      @mq.topic("amalgamaton").publish("keyup,#{x},#{y})")
    end

    def conduct!
      action, x, y = @monome.read
      case action
      when :keydown
        keydown(x, y)
      when :keyup
        keyup(x, y)
      else
        puts "ACTION: #{action.inspect} (#{x}, #{y})"
      end
    end
    
    def tick!
      @tick = ((@tick || 0) + 1) % 8
      message = "{'action':'tick','offset':#{@tick}}"
      puts message
      @mq.topic("amalgamaton").publish(message)
    end

  end

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

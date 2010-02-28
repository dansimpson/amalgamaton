require 'rubygems'
require 'mq'
require 'sequencer'



AMQP.start(:host => "localhost") do

  @channel = MQ.new.topic("amalgamaton")

  preload @channel, [{
    :id => "beat",
    :url => "media/samples/club-dance-beat-005.mp3"
  },{
    :id => "exotic",
    :url => "media/samples/exotic-sarod-01.mp3"
  },{
    :id => "bass",
    :url => "media/samples/upright-funk-bass-05.mp3"
  }]


  delay 4.seconds do
    every 8.seconds do
      play @channel, "bass"
    end
  end

  delay 8.seconds do
    every 8.seconds do
      play @channel, "exotic"
    end
  end
  
end
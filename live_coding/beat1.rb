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


  every 8.seconds do
    play @channel, "bass", "bass"
    play @channel, "beat", "drums"
  end

  delay 8.seconds do
  every 16.seconds do
    play @channel, "exotic", "guitar"
  end
  end
 

end 

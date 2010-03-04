require 'json'

class Fixnum
  def seconds
    return self
  end
  
  def ms
    return self / 1000
  end
  
  def minutes
    return self * 60
  end
end

def every time, opts={}, &block
  unless opts[:initial] && opts[:initial] == false
    block.call
  end

  EM.add_periodic_timer(time, block)
end

def play channel, sample, family, time=nil
  if time
    EM.add_timer(time) do
      stop channel, sample, family
    end
  end
  channel.publish(%({"action":"play","items":["#{sample}"]}), :key => "conductor")
end

def stop channel, sample
  channel.publish(%({"action":"stop","items":["#{sample}"]}), :key => "conductor")
end

def delay time, &block
  EM.add_timer(time, block)
end

def preload channel, items
  channel.publish({
    :action => "preload",
    :items => items
  }.to_json)
end

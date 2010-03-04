require 'monome_serial'
require 'monome_dummy'
require 'grid'

class Monome
  
  attr_accessor :grid
  
  def initialize
    @grid = Grid.new
    
    begin
      @monome = MonomeSerial.detect_monome
    rescue
      @monome = MonomeDummy.new
    end
    @activate_blocks = []
    @deactivate_blocks = []
    @clear_blocks = []
    @refresh_blocks = []
  end
  
  def toggle!(x, y)
    puts "Toggling #{[x, y]}"
    @grid.toggle!(x, y)
    @grid[x, y] ? activate(x, y) : deactivate(x, y)
  end
  
  def clear!
    @grid.clear!
    @clear_blocks.each do |block|
      block.call
    end
  end
  
  def on_activate(&block)
    @activate_blocks << block
  end
  
  def on_deactivate(&block)
    @deactivate_blocks << block
  end
  
  def on_clear(&block)
    @clear_blocks << block
  end
  
  def on_refresh(&block)
    @refresh_blocks << block
  end
  
  def activate(x, y)
    puts "Activating #{[x, y]}"
    @monome.illuminate_lamp(x, y)
    @activate_blocks.each do |block|
      block.call(x, y)
    end
  end
  
  def deactivate(x, y)
    puts "Deactivating #{[x, y]}"
    @monome.extinguish_lamp(x, y)
    @deactivate_blocks.each do |block|
      block.call(x, y)
    end
  end
  
  def refresh
    puts "Refreshing client(s)"
    @refresh_blocks.each do |block|
      block.call
    end
  end
  
  
  
  def read!
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
  
  def keydown(x, y)
    puts "Keydown #{[x, y]}"
    toggle!(x, y)
  end
  
  def keyup(x, y)
    puts "Keyup #{[x, y]}"
  end
  
  

end

# monome = Monome.new
# monome.run!
# 
# @mq.queue(rand().to_s).bind(@mq.topic("amalgamaton"), :key => family).subscribe do |msg|
#   p msg
#   push msg
# end


class Sequencer

  attr_accessor :samples
  
  def initialize(beats, monome)
    @monome = monome
    @grid = monome.grid
    @beats = beats
    @count = 0
    @samples = []
    @preload_blocks = []
  end
  
  def tick!
    @count = (@count + 1) % @beats
  end
  
  def on_preload(&block)
    @preload_blocks << block
  end
  
  def preload
    @preload_blocks.each do |block|
      block.call(samples)
    end
  end

end
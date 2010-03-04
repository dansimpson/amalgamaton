class Grid

  def initialize(size=8)
    @size = size
    self.clear!
  end
  
  def []=(x, y, val)
    @rows[y][x] = val
  end
  
  def [](x, y)
    @rows[y][x]
  end
  
  def toggle!(x, y)
    self[x, y] = !self[x, y]
  end
  
  def clear!
    @rows = Array.new(@size)
    @rows.collect!{ Array.new(@size, false) }
  end
  
  def to_json
    require 'json'
    @rows.to_json
  end
  
  def col(x)
    @rows.collect { |row| row[x] }
  end
  
end
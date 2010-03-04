# Class: Orchestra
#
#

class Orchestra
  
end



# class Orchestra
# 
#   def initialize(mq)
#     @monome = MonomeSerial.detect_monome
#     @grid = Hash.new
#     @mq = mq
#     @offset = Hash.new
#   end
# 
#   def keydown(x, y)
#     message = %({"action":"keydown","x":#{x},"y":#{y}})
#     puts message
#     @mq.topic("amalgamaton").publish(message)
#     @offset[y] = x
#   end
# 
#   def keyup(x, y)
#     message = %({"action":"keyup","x":#{x},"y":#{y}})
#     puts message
#     @mq.topic("amalgamaton").publish(message)
#   end
# 
#   def conduct!
#     action, x, y = @monome.read
#     case action
#     when :keydown
#       keydown(x, y)
#     when :keyup
#       keyup(x, y)
#     else
#       puts "ACTION: #{action.inspect} (#{x}, #{y})"
#     end
#   end
#   
#   def tick!
#     @tick = ((@tick || 0) + 1) % 8
#     message = %({"action":"tick","offset":#{@tick}})
#     puts message
#     @mq.topic("amalgamaton").publish(message)
#     @offset.keys.each do |y|
#       x = @tick + @offset[y]
#       @monome.extinguish_lamp(x - 1 % 8 + 1, y)
#       @monome.illuminate_lamp(x % 8 + 1, y)
#     end
#   end
# 
# end
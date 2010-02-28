require "mq"

class MusicGroup < EM::Channel

	def initialize
		super

		@mq = MQ.new
		@mq.queue("ws1").bind(@mq.topic("amalgamaton"), :key => "#").subscribe do |msg|
			push msg
		end
	end

end

class MusicHandler < Funnel::WebSocket::Connection

	@@group = nil
	
	#called when the connection is ready to send
	#and receive data
	def on_ready
		unless @@group
			@@group = MusicGroup.new
		end
		
		puts "Ready..."
		@sid = @@group.subscribe do |msg|
			send_message msg
		end
	end
	
	#called on disconnect
	def on_disconnect
		puts "Ended"
		@@group.unsubscribe(@sid)
	end
	
	#right back at you
	def on_data msg
		send_message msg
	end

end
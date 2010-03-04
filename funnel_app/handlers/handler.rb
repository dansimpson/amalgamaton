require "mq"
require "json"

class MusicGroup < EM::Channel

	def initialize
		super
		@mq = MQ.new
		@mq.queue(rand().to_s).bind(MusicGroup.topic, :key => "conductor").subscribe("auto-delete".intern => false) do |msg|
			push msg
		end
	end
	
	def self.topic
		@@topic ||= MQ.new.topic("amalgamaton")
	end
	
	def self.publish msg
		topic.publish(msg, :key => "orchestra")
	end
	
end

class MusicHandler < Funnel::WebSocket::Connection

	@@channel = nil

	#called when the connection is ready to send
	#and receive data
	def on_ready
		@@channel = MusicGroup.new if @@channel.nil?
		
		@sid = @@channel.subscribe do |msg|
			send_message msg
		end
		
		log "connect"
	end
	
	#called on disconnect
	def on_disconnect
		@@channel.unsubscribe(@sid)
		log "disconnect"
	end
	
	#right back at you
	def on_data msg
		data = JSON.parse(msg) rescue false
		if data
			case data["action"]
			when "click"
				MusicGroup.publish msg
			when "refresh"
				MusicGroup.publish msg
			else
				log "unknown action: #{data["action"]}"
			end
		end
	end
	
	private
	
	def log msg
		p "#{Time.now} - #{msg}"
	end

end
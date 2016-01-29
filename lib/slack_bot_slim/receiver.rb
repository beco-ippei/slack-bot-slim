require 'faye/websocket'
require 'eventmachine'

module SlackBotSlim
  class Receiver
    def initialize(url, bot)
      @url = url
      @bot = bot
    end

    def start(&block)
      EM.run do
        ws = Faye::WebSocket::Client.new(@url)

        ws.on :open do |event|
          puts 'Successfully connected.'
        end

        ws.on :message do |event|
          data = JSON.parse(event.data)
          case type = data["type"].to_sym
          when :message
            yield JSON.parse(event.data)
          when :user_typing, :presence_change
            # do nothing
          when :reconnect_url
            @reconnect_url = data['url']
          else
            puts "--- :#{type} ---", data
          end
        end

        ws.on :close do |event|
          puts 'connection closed'
          p event
          self.stop
        end

        Signal.trap("INT")  { self.stop }
        Signal.trap("TERM") { self.stop }
      end
    end

    def stop
      puts "stopped"
      EM.stop
    end
  end
end


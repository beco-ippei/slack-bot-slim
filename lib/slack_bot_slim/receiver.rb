require 'faye/websocket'
require 'eventmachine'

module SlackBotSlim
  class Receiver
    attr_reader :bot_self

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
          case data["type"].to_sym
          when :message
            yield JSON.parse(event.data)
          else
            #p "---", event
          end
          #if !data["type"].nil? && !@callbacks[data["type"].to_sym].nil?
          #  @callbacks[data["type"].to_sym].each do |c|
          #    c.call data
          #  end
          #end
        end

        ws.on :close do |event|
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

    private

    def receive_message
      loop do
        data = receive {|msg| msg }
        @bot.handle_message data
      end
    end
  end
end


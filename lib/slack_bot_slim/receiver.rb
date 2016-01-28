require 'websocket-client-simple'

module SlackBotSlim
  class Receiver
    def initialize(url, bot)
      @url = url
      @bot = bot
    end

    def start(&block)
      ws = WebSocket::Client::Simple.connect @url

      ws.on :message do |event|
        type, data = handle event
        case type
        when :message
          yield data
        else
          puts "--- #{type} ---", data
        end
      end

      ws.on :open do
        puts 'Successfully connected.'
      end

      ws.on :close do |event|
        puts 'connection closed'
        self.stop
      end

      Signal.trap("INT")  { self.stop }
      Signal.trap("TERM") { self.stop }

      loop do
        #TODO
        cmd = STDIN.gets.strip
        case cmd
        when /^exit$/i
          self.stop
        else
          puts "..."
        end
      end
    end

    def stop
      puts "stopped"
      exit
    end

    private

    def handle(event)
      data = JSON.parse(event.data)
      type = data["type"].to_sym
      data = case type
             when :message
               puts 'message ...'
               JSON.parse(event.data)
             else
               puts "--- #{type} ---", data
             end
      [type, data]
    end
  end
end


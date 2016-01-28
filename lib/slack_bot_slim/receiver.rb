require 'websocket-client-simple'

module SlackBotSlim
  class Receiver
    def initialize(url, bot)
      @url = url
      @bot = bot
    end

    def start(&block)
      ws = WebSocket::Client::Simple.connect @url
      unless ws
        #TODO
      end

      ws.on :message do |event|
        data = JSON.parse(event.data)
        case type = data["type"].to_sym
        when :message
          yield data
        when :user_typing, :presence_change
          # do nothing
        when :reconnect_url
          @reconnect_url = data['url']
        else
          puts "--- :#{type} ---", data
        end
      end

      ws.on :open do
        puts 'Successfully connected.'
      end

      ws.on :close do |event|
        puts 'connection closed'
        if @reconnect_url
          puts 'reconnect ...'
          ws = WebSocket::Client::Simple.connect @reconnect_url
        else
          self.stop
        end
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
  end
end


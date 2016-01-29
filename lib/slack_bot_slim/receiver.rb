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
        p '----------', ws

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
          puts 'connection closed'
          p event
          self.stop
        end

        Signal.trap("INT")  { self.stop }
        Signal.trap("TERM") { self.stop }
      end
    end

    def _start(&block)
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
      #exit
      EM.stop
    end
  end
end


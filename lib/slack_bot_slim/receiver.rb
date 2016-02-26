require 'faye/websocket'
require 'eventmachine'

module SlackBotSlim
  class Receiver
    def initialize(url, bot)
      @url = url
      @bot = bot
      @restart = true
    end

    def start
      while @restart
        EM.run do
          ws = Faye::WebSocket::Client.new(@url)

          ws.on :open do |event|
            @bot.log 'Successfully connected.'
          end

          ws.on :message do |event|
            handle_event event
          end

          ws.on :close do |event|
            @bot.log "connection closed: [%s] '%s'" %
                [event.code, event.reason]
            self.stop
          end

          Signal.trap("INT")  { self.stop }
          Signal.trap("TERM") { self.stop }
        end
      end
    end

    def stop(mode = nil)
      @restart = (mode == :restart)

      EM.stop

      if @restart
        @bot.log 'restart connection'
      else
        @bot.log "stopped"
      end
    end

    private

    def handle_event(event)
      data = JSON.parse(event.data)

      case type = data["type"].to_sym
      when :message
        @bot.handle_message data
      when :team_migration_started
        @bot.log "#{type}: stop and restart"
        self.stop :restart
      when :reconnect_url
        @url = data['url']
      else
        # do nothing
        # if you want add reactions,
        # refar to https://api.slack.com/rtm
        # ex. user or team add/change.
        print '.'
      end
    end
  end
end


require 'faye/websocket'
require 'eventmachine'

module SlackBotSlim
  class Receiver
    IGNORE_EVENTS = [
      :user_typing,
      :presence_change,
      :file_shared,
      :file_public,
      :reaction_added,
    ]

    def initialize(url, bot, auto_restart = false)
      @url = url
      @bot = bot
      @restart = auto_restart
    end

    def start(&block)
      while true
        @restart = false   # reset

        EM.run do
          ws = Faye::WebSocket::Client.new(@url)

          ws.on :open do |event|
            @bot.log 'Successfully connected.'
          end

          ws.on :message do |event|
            data = JSON.parse(event.data)
            case type = data["type"].to_sym
            when :message
              yield JSON.parse(event.data)
            when :team_migration_started
              @bot.log "#{type}: stop and restart"
              self.restart
            when *IGNORE_EVENTS
              # do nothing
              print '.'     #TODO: debuging
            when :reconnect_url
              @url = data['url']
            else
              @bot.log "--- :#{type} ---", data
            end
          end

          ws.on :close do |event|
            @bot.log "connection closed: [%s] '%s'" %
                [event.code, event.reason]
            self.stop
          end

          Signal.trap("INT")  { self.stop }
          Signal.trap("TERM") { self.stop }
        end

        EM.run do
          # check state
          tick = EM.tick_loop do
            msg = %x[cat msg 2>/dev/null].chomp
            sleep 5
            case msg
            when 'stop'
              :stop
            when 'restart'
              self.restart
            when nil, ''
              print '-'     #TODO debug
            else
              print 'o'
            end
          end

          tick.on_stop do
            @restart = false
            self.stop
          end
        end

        break if @restart == false
      end
    end

    def restart
      @bot.log 'restart connection'
      @restart = true
      self.stop
    end

    def stop
      @bot.log "stopped"
      EM.stop
    end
  end
end


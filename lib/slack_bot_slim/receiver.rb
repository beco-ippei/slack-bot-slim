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

          @checker = Thread.start do
            # check state
            while true
              sleep 60    #TODO be env
              if cmd = check_connection
                self.stop cmd
              end
            end
          end
        end

        self.stop_checker
      end
    end

    def stop(mode = nil)
      @restart = (mode == :restart)

      self.stop_checker
      EM.stop

      if @restart
        @bot.log 'restart connection'
      else
        @bot.log "stopped"
      end
    end

    private

    def stop_checker
      if @checker && @checker.alive?
        @checker.kill
      end
    end

    def handle_event(event)
      data = JSON.parse(event.data)

      case type = data["type"].to_sym
      when :message
        @bot.handle_message data
      when :team_migration_started
        @bot.log "#{type}: stop and restart"
        self.stop :restart
      when *IGNORE_EVENTS
        # do nothing
        print '.'     #TODO: debuging
      when :reconnect_url
        @url = data['url']
      else
        @bot.log "--- :#{type} ---", data
      end
    end

    def check_connection
      msg = %x[cat msg 2>/dev/null].chomp
      print '*'   #TODO: debug

      if @bot.alive?
        # ok
      elsif msg == 'stop'
        :stop
      else
        :restart
      end
    end
  end
end


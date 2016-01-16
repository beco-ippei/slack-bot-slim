require 'slack'

module SlackBotSlim
  class Bot
    attr_reader :api, :user, :user_id

    def self.token=(token)
      #TODO
      @@token = token
    end

    def self.icon=(icon_emoji)
      @@icon = icon_emoji
    end

    def icon
      @@icon
    end

    def self.generate
      @@bot ||= self.new(@@token)
      SlackBotSlim::Message.bot = @@bot
      @@bot
    end

    def initialize(token)
      Slack.configure do |config|
        config.token = token
      end

      ok, error = auth
      unless ok
        raise Exception.new "auth failed : '#{error}'"
      end

      @client = Slack.realtime

      @reactions = {
        ambient: [],
        mention: [],
      }

      @api = Slack::API.new
    end

    def auth
      res = Slack.auth_test

      puts "auth test: " +
        res.map{|k,v| "#{k}:'#{v}'" }.join(', ')

      @url = res['url']
      @team = res['team']
      @team_id = res['team_id']
      @user = res['user']
      @user_id = res['user_id']

      [res['ok'], res['error']]
    end

    def start_waiting
      @client.on :hello do
        puts 'Successfully connected.'
      end

      @client.on :message do |data|
        handle_message data
      end

      Signal.trap("INT")  { self.stop }
      Signal.trap("TERM") { self.stop }

      @client.start
    end

    def stop
      puts "stopped"
      EventMachine.stop
    end

    def hear(types, patterns, priority = 0, &block)
      types = [types] unless types.is_a? Array
      types.each do |type|
        unless valid_type? type
          raise "invalid type '#{type}'"
        end

        @reactions[type] << [
          priority,
          patterns,     #TODO: multiple ?
          block,
        ]
      end
      nil
    end

    private

    def handle_message(data)
      msg = SlackBotSlim::Message.new data
      return unless msg.user_id

      puts "receive message: #{msg.text}"

      #TODO check type and call typed method

      @reactions[:ambient].each do |(_, ptn, prc)|
        if matched = ptn.match(msg.text)
          msg.matched = matched
          prc.call msg
        end
      end
    rescue => ex
      puts "Exception in handle message : #{ex.message}"
      puts ex.backtrace.join("\n\t")
    end

    def valid_type?(type)
      [:ambient, :mention].include? type
    end
  end
end

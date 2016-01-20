require 'slack'

module SlackBotSlim
  class Bot
    attr_reader :api, :user, :user_id, :icon

    def self.token=(token)
      #TODO
      @@token = token
    end

    def self.bot
      @@bot ||= self.new(@@token)
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
      @api = SlackBotSlim::Api.new
      fetch_bot_user_info

      @client = Slack.realtime

      @reactions = {
        ambient: [],
        dm: [],
        mention: [],
      }
    end

    def start
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

    def hear(types, pattern, priority = 0, &block)
      types = [types] unless types.is_a? Array
      types.each do |type|
        unless valid_type? type
          raise "invalid type '#{type}'"
        end

        @reactions[type] << [
          priority,
          pattern,
          block,
        ]
      end
      nil
    end

    def send_message(params)
      _params = {
        username: user,
        icon_url: icon,
      }.merge(params)
      api.chat_postMessage _params
    end

    private

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

    def fetch_bot_user_info
      puts 'fetch bot user info'
      info = @api.users_info user: @user_id
      @icon = info['user']['profile']['image_48']
    end

    def handle_message(data)
      p :handle_message, data
      msg = SlackBotSlim::Message.new data
      return unless msg.user_id

      puts "receive message: #{msg.text}"

      #TODO check type and call typed method

      @reactions[:dm].each do |(_, ptn, prc)|
        if matched = ptn.match(msg.text)
          msg.matched = matched
          prc.call msg
        end
      end

      @reactions[:ambient].each do |(_, ptn, prc)|
        if matched = ptn.match(msg.text)
          msg.matched = matched
          prc.call msg
        end
      end
    rescue => ex
      puts "Exception in handle message : #{ex.message}"
      puts ex.backtrace.join("\n\t")
      #send_message(
      #  channel: data['channel'],
      #  text: "error : '#{ex.message}'",
      #)
    end

    def valid_type?(type)
      [:ambient, :dm, :mention].include? type
    end
  end
end

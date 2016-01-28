module SlackBotSlim
  class Bot
    attr_reader :api, :user, :user_id, :icon

    def self.token=(token)
      Slack.configure do |config|
        config.token = token
      end
    end

    def self.instance
      @@bot ||= self.new
      @@bot
    end

    def initialize
      ok, error = auth
      unless ok
        raise "auth failed : '#{error}'"
      end
      @api = SlackBotSlim::Api.new
      @icon = @api.bot_info['profile']['image_48']

      @reactions = {
        ambient: [],
        dm: [],
        mention: [],
      }
    end

    def start
      @receiver = @api.receiver
      @receiver.start do |data|
        handle_message data
      end
    end

    def stop
      @receiver.stop
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

      puts "auth test: #{res}"

      @url = res['url']
      @team = res['team']
      @team_id = res['team_id']
      @user = res['user']
      @user_id = res['user_id']

      [res['ok'], res['error']]
    end

    def handle_message(data)
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
      send_message(
        channel: data['channel'],
        text: "error : '#{ex.message}'",
      )
    end

    def valid_type?(type)
      [:ambient, :dm, :mention].include? type
    end
  end
end

module SlackBotSlim
  class Bot
    attr_reader :api, :user, :user_id, :icon

    VALID_TYPES = [:ambient, :dm, :mention, :all]

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

      @reactions = {}
    end

    #TODO: sort by priority
    def start
      @receiver = @api.receiver
      @receiver.start
    end

    def stop
      @receiver.stop
    end

    # add bot responds pattern & procs
    # if matched but won't continue,
    # block should return 'false'
    def hear(type, pattern, priority = 0, &block)
      #TODO split type of methods ?
      unless valid_type? type
        raise "invalid type '#{type}'"
      end

      @reactions[type] ||= []
      @reactions[type] << [
        priority,
        pattern,
        block,
      ]
      nil
    end

    def send_message(params)
      _params = {
        username: user,
        icon_url: icon,
      }.merge(params)
      api.chat_postMessage _params
    end

    def alive?
      res = api.users_getPresence user: user_id
      res && res['presence'] == 'active'
    end

    def log(*msg)
      time = Time.now.strftime '%Y-%m-%d %H:%M:%S'
      puts "[#{time}]: #{msg.join ' '}"
    end

    def handle_message(data)
      msg = SlackBotSlim::Message.new data

      if msg.text.nil?
        return
      elsif msg.mine?
        return      # bot's message
      elsif msg.bot? && !msg.dm? && !msg.mentioned?
        #return      #TODO: ignore if not mentioned
      end

      #TODO check type and call typed method

      #TODO handle im ?
      types = if msg.dm?
                [:dm, :all]
              elsif msg.mentioned?
                [:dm, :mention, :all]
              else
                [:ambient, :all]
              end

      pattern_matched = false
      types.each do |type|
        next unless @reactions[type]
        @reactions[type].each do |(_, ptn, prc)|
          if matched = ptn.match(msg.text)
            msg.matched = matched
            pattern_matched = true
            consumed = prc.call msg
            if consumed != false
              return    # consumed
            end
          end
        end
      end

      #TODO: unless matched patterns (consumed option)
      unless pattern_matched
        log "unmached message: %s" % msg.text
      end

    rescue => ex
      log "Exception in handle message : #{ex.message}"
      log ex.backtrace.join("\n\t")
      send_message(
        channel: data['channel'],
        text: "error : '#{ex.message}'",
      )
    end

    private

    def auth
      res = Slack.auth_test

      log "auth test: #{res}"

      @url = res['url']
      @team = res['team']
      @team_id = res['team_id']
      @user = res['user']
      @user_id = res['user_id']

      [res['ok'], res['error']]
    end

    def valid_type?(type)
      VALID_TYPES.include? type
    end
  end
end

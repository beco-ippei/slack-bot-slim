module SlackBotSlim
  #TODO: sample
  #{"type"=>"message", "channel"=>"C03AG3JLV", "user"=>"U037TD3QY", "text"=>"<@U0J8MEWLR>: hello", "ts"=>"1452790318.000135", "team"=>"XXXXXXXXX", :message=>#<MatchData "hello">}
  class Message
    @@bot = nil
    attr_reader :type, :text, :match,
      :user, :user_id, :channel, :channel_id,
      :ts, :time, :team, :team_id

    def initialize(data)
      @type = data['type']
      @text = data['text']

      self.channel = data['channel']
      self.user = data['user']
      self.time = data['ts'].to_f
      self.team = data['team']
    end

    def self.bot=(bot)
      @@bot = bot
    end

    def matched=(matched)
      @match = matched
    end

    def reply(message)
      params = {
        channel: @channel_id,
        username: bot.user,
        icon_emoji: bot.icon,
        text: message,
      }
      bot.api.chat_postMessage params
    end

    private

    def bot
      @@bot
    end

    def channel=(channel_id)
      #TODO channel class ?
      @channel_id = channel_id
      @channel = bot.api.channel(channel_id)['name']
    end

    def user=(user_id)
      if user_id
        #TODO user class
        @user_id = user_id
        @user = bot.api.user(user_id)['name']
      end
    end

    def team=(team_id)
      #TODO team class or not ?
      @team_id = team_id
    end

    def time=(epoch)
      @ts = epoch
      @time = Time.at epoch
    end
  end
end

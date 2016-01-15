module SlackBotSlim
  #TODO: sample
  #{"type"=>"message", "channel"=>"C03AG3JLV", "user"=>"U037TD3QY", "text"=>"<@U0J8MEWLR>: hello", "ts"=>"1452790318.000135", "team"=>"XXXXXXXXX", :message=>#<MatchData "hello">}
  class Message
    @@bot = nil
    attr_accessor :type, :channel, :user, :text,
      :ts, :team, :match

    def initialize(data)
      @type = data['type']
      @channel = data['channel']
      @user = data['user']
      @text = data['text']
      @ts = data['ts']
      @team = data['team']
      @match = data[:match]
    end

    def self.bot=(bot)
      @@bot = bot
    end

    def reply(message)
      params = {
        channel: self.channel,
        username: bot.name,      #TODO
        icon_emoji: ':japanese_goblin:',
        text: message,
      }
      bot.api.chat_postMessage params
    end

    private

    def bot
      @@bot
    end
  end
end

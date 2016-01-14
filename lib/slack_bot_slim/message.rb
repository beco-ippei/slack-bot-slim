module SlackBotSlim
  #TODO: sample
  #{"type"=>"message", "channel"=>"C03AG3JLV", "user"=>"U037TD3QY", "text"=>"<@U0J8MEWLR>: hello", "ts"=>"1452790318.000135", "team"=>"T037TD3QW", :message=>#<MatchData "hello">}
  class Message
    attr_accessor :type, :channel, :user, :text,
      :ts, :team, :match

    def initialize(data, bot)
      @type = data['type']
      @channel_id = data['channel']
      @user_id = data['user']
      @text = data['text']
      @ts = data['ts']
      @team_id = data['team']
      @match = data[:match]
    end
  end
end

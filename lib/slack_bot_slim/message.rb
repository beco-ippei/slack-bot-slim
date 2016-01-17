module SlackBotSlim
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

    def matched=(matched)
      @match = matched
    end

    def reply(message)
      bot.send_message(
        channel: @channel_id,
        text: message,
      )
    end

    private

    def bot
      @@bot ||= SlackBotSlim::Bot.bot
      @@bot
    end

    def channel=(channel_id)
      @channel_id = channel_id
      @channel = bot.api.channel(channel_id)['name']
    end

    def user=(user_id)
      if user_id
        @user_id = user_id
        @user = bot.api.user(user_id)['name']
      end
    end

    def team=(team_id)
      @team_id = team_id
      #TODO: @team
    end

    def time=(epoch)
      @ts = epoch
      @time = Time.at epoch
    end
  end
end

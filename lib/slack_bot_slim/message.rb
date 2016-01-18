module SlackBotSlim
  class Message
    @@bot = nil
    attr_reader :type, :text, :match,
      :user, :user_id, :channel, :channel_id,
      :ts, :time, :team, :team_id

    def initialize(data)
      @type = data['type']

      self.text = data['text']
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

    def text=(text)
      @original_text = text

      @text = text
    end

    def parse_text(text)
      text.strip!
      if m = /^[\s　]*<@([^>]+)>[:\s](.*)$/.match(text)
        dm = m[1]
        text = m[2].strip
      end

      mentions = text.scan(/<@([^>]+)>/).map(&:first)

      {
        dm: dm,
        mentions: mentions,
        text: text,
      }
    end

    def channel=(channel_id)
      if channel_id
        @channel_id = channel_id
        @channel = bot.api.channel(channel_id)['name']
      end
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

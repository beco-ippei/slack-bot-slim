module SlackBotSlim
  class Message
    @@bot = nil
    attr_reader :type, :text, :match,
      :user, :user_id, :channel, :channel_id,
      :ts, :time, :team, :team_id

    def initialize(data)
      @type = data['type']
      @data = data

      fetch_text data
      #TODO: 各項目がnilになるケースなど
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

    def dm?
      if !@dm
        false
      elsif bot?
        @dm.include? bot.user
      else
        @dm.include? bot.user_id
      end
    end

    def mentioned?
      if @mentions.nil?
        false
      elsif bot?
        @mentions.include? bot.user
      else
        @mentions.include? bot.user_id
      end
    end

    def bot?
      @data['subtype'] == "bot_message"
    end

    private

    def bot
      @@bot ||= SlackBotSlim::Bot.instance
      @@bot
    end

    def fetch_text(data)
      if data['text']
        self.text = data['text']
      else
        # from 'attachments'
        attachments = data['attachments']
        if attachments
          atch = attachments.first
          self.text = if atch['text']
                       atch['text']
                     elsif atch['pretext']
                       atch['pretext']
                     end
        end
      end
    end

    def text=(text)
      @original_text = text

      if text
        data = parse_text text
        @dm = data[:dm]
        @mentions = data[:mentions]
        @text = data[:text]
      end
    end

    def parse_text(text)
      text.strip!
      dm_ptn = /^[\s　]*<@([^>]+)>[:\s](.*)$/
      if m = dm_ptn.match(text)
        dm = m[1].split('|')
        text = m[2].strip
      end

      #TODO IFTTT?
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
        channel = bot.api.channel(channel_id)
        @channel = channel['name'] if channel
      end
    end

    def user=(user_id)
      if user_id
        @user_id = user_id
        user = bot.api.user(user_id)
        @user = user['name'] if user
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

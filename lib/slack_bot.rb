require 'slack'

class SlackBot
  attr_reader :api
  @@bot = nil

  def self.token=(token)
    #TODO
    @@token = token
  end

  def self.generate
    @@bot = self.new(@@token) unless @@bot
    @@bot
  end

  def initialize(token)
    Slack.configure do |config|
      config.token = token
    end

    p Slack.auth_test
    @client = Slack.realtime

    @reactions = {
      ambient: [],
      mention: [],
    }

    @api ||= Slack::API.new
  end

  def start_waiting
    @client.on :hello do
      puts 'Successfully connected.'
    end

    @client.on :message do |data|
      text = data['text']
      puts "receive message: #{text}"

      #TODO check type and call typed method

      @reactions[:ambient].each do |(_, pattern, prc)|
        if matched = pattern.match(text)
          data[:message] = matched
          prc.call data
        end
      end
    end
    #TODO: catch interrupt

    @client.start
  rescue => ex
    p ex
  end

  def hear(types, patterns, priority = 0)
    types = [types] unless types.is_a? Array
    types.each do |type|
      unless valid_type? type
        raise "invalid type '#{type}'"
      end

      @reactions[type] << [
        priority,
        patterns,     #TODO: multiple ?
        lambda {|msg| yield msg },
      ]
    end
    nil
  end

  #TODO: better for msg.reply
  def reply(data, text)
    params = {
      channel: data['channel'],
      username: 'rubot',      #TODO
      icon_emoji: ':japanese_goblin:',
      text: text,
    }
    api.chat_postMessage params
  end

  private

  def valid_type?(type)
    [:ambient, :mention].include? type
  end
end

require 'slack'

module SlackBotSlim
  class Bot
    attr_reader :api
    @@bot = nil

    def self.token=(token)
      #TODO
      @@token = token
    end

    def self.name=(name)
      #TODO
      @@name = name
    end

    def self.generate
      unless @@bot
        @@bot = self.new(@@token)
        SlackBotSlim::Message.bot = @@bot
      end
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
        msg = SlackBotSlim::Message.new data
        puts "receive message: #{msg.text}"

        #TODO check type and call typed method

        @reactions[:ambient].each do |(_, pattern, prc)|
          if matched = pattern.match(msg.text)
            msg.match = matched
            prc.call msg
          end
        end
      end
      #TODO: catch interrupt

      @client.start
    rescue => ex
      p ex
    end

    #def hear(types, patterns, priority = 0)
    def hear(types, patterns, priority = 0, &block)
      types = [types] unless types.is_a? Array
      types.each do |type|
        unless valid_type? type
          raise "invalid type '#{type}'"
        end

        @reactions[type] << [
          priority,
          patterns,     #TODO: multiple ?
          block,
        ]
      end
      nil
    end

    def name
      @@name
    end

    private

    def valid_type?(type)
      [:ambient, :mention].include? type
    end
  end
end

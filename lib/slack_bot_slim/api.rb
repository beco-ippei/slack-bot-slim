module SlackBotSlim
  class Api
    attr_reader :users, :channels, :bot_info

    def self.instance
      @@instance ||= self.new
      @@instance
    end

    def initialize
      @api = Slack::API.new
      @users = {}
      @channels = {}

      #TODO
      #def @api.rtm_start
      #  post("rtm.start")
      #end

      res = @api.send :post, "rtm.start"
      unless res['ok']
        raise 'rtm connection failed'
      end

      merge_channels res['channels']
      merge_users res['users']
      @bot_info = res['users'].detect do |e|
        e['id'] == res['self']['id']
      end
      @rtm_url = res['url']
    end

    def receiver
      #res = @api.rtm_start
      #unless res['ok']
      #  raise 'rtm connection failed'
      #end

      #merge_channels res['channels']
      #merge_users res['users']

      bot = SlackBot.instance
      SlackBotSlim::Receiver.new @rtm_url, bot
    end

    def user(id)
      unless @users.has_key? id
        fetch_users
        unless @users.has_key? id
          @users[id] = nil  # never fetch again
        end
      end

      @users[id]
    end

    def channel(id)
      unless @channels.has_key? id
        fetch_channels
        unless @channels.has_key? id
          @channels[id] = nil   # never fetch again
        end
      end

      @channels[id]
    end

    private

    def fetch_users
      res = @api.users_list
      unless res['ok']
        raise "Api fetch error : '#{res['error']}'"
      end
      merge_users res['members']
    end

    def merge_users(users)
      users.each do |e|
        @users[e['id']] = e
      end
    end

    def fetch_channels
      res = @api.channels_list
      unless res['ok']
        raise "Api fetch error : '#{res['error']}'"
      end
      merge_channels res['channels']
    end

    def merge_channels(channels)
      channels.each do |e|
        @channels[e['id']] = e
      end
    end

    def method_missing(method, *args)
      if @api.public_methods.include?(method.to_sym)
        @api.send method.to_sym, *args
      else
        raise NameError.new(
          "undefined method `%s' for class `%s'" %
            [method, self.class],
          method
        )
      end
    end
  end
end


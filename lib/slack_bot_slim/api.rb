module SlackBotSlim
  class Api
    attr_reader :users, :channels

    def initialize
      @api = Slack::API.new

      puts 'fetch initial lists'
      fetch_users
      fetch_channels
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

      @users = res['members'].inject({}) do |h, e|
        h[e['id']] = e
        h
      end
    end

    def fetch_channels
      res = @api.channels_list
      unless res['ok']
        raise "Api fetch error : '#{res['error']}'"
      end

      @channels = res['channels'].inject({}) do |h, e|
        h[e['id']] = e
        h
      end
    end

    def method_missing(method, *args)
      if @api.public_methods.include?(method.to_sym)
        @api.send method.to_sym, *args
      else
        raise NameError.new(
          "undefined method `%s' for class `%s'" %
            method, self.class,
          method
        )
      end
    end
  end
end


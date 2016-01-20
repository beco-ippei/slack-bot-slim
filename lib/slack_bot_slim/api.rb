module SlackBotSlim
  class Api
    attr_reader :users, :channels, :ims

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

    def _channel(id)
      unless @channels.has_key? id
        fetch_channels
        unless @channels.has_key? id
          @channels[id] = nil   # never fetch again
        end
      end

      @channels[id]
    end

    def channel(id)
      if @channels.has_key? id
        @channels[id]
      elsif @ims.has_key? id
        #TODO 同じ扱いなら一個のcollection?
        @ims[id]
      else
        fetch_channels
        fetch_ims
        if @channels.has_key? id
          @channels[id]
        elsif @ims.has_key? id
          @ims[id]
        else
          @channels[id] = nil
          @ims[id] = nil
          nil
        end
      end
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
      @channels ||= {}
      {
        channels: ['channels', @api.channels_list],
        ims: ['ims', @api.im_list],
        groups: ['groups', @api.groups_list],
        mpim: ['groups', @api.mpim_list],
      }.each do |name, (key, res)|
        unless res['ok']
          raise "failed api fetch: #{name} '#{res['error']}'"
        end

        res[key].each do |v|
          @channels[v['id']] = v
        end
      end
    end

    def fetch_ims
      res = @api.im_list
      unless res['ok']
        raise "Api fetch error : '#{res['error']}'"
      end

      @ims = res['ims'].inject({}) do |h, e|
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


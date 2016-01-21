require 'faye/websocket'
require 'celluloid'

module SlackBotSlim
  class Receiver
    include Celluloid

    attr_reader :bot_self

    def initialize(url, bot)
      @url = url
      @bot = bot
    end

    def start
      puts "starting receiver"

      ws = Faye::WebSocket::Client.new(@url)
      self.async.receive_message

      ws.on :open do |event|
        puts 'Successfully connected.'
      end

      ws.on :message do |event|
        self.mailbox << JSON.parse(event.data)
        #if !data["type"].nil? && !@callbacks[data["type"].to_sym].nil?
        #  @callbacks[data["type"].to_sym].each do |c|
        #    c.call data
        #  end
        #end
      end

      ws.on :close do |event|
        self.mailbox << nil
      end
    end

    #def initialize
    #  async.wait
    #end

    #def wait
    #  loop do
    #    message = receive{|msg| msg.is_a? String }
    #    puts "received: #{message}"
    #  end
    #end
#  end
#
#receiver = Receiver.new
#
#receiver.mailbox << "one"
#receiver.mailbox << 1
#receiver.mailbox << "two"




    #def start
    #  ws = Faye::WebSocket::Client.new(@url)

    #  ws.on :open do |event|
    #  end

    #  ws.on :message do |event|
    #    data = JSON.parse(event.data)
    #    if !data["type"].nil? && !@callbacks[data["type"].to_sym].nil?
    #      @callbacks[data["type"].to_sym].each do |c|
    #        c.call data
    #      end
    #    end
    #  end

    #  ws.on :close do |event|
    #    EM.stop
    #  end



    #  ws.on :hello do
    #    puts 'Successfully connected.'
    #  end

    #  @client.on :message do |data|
    #    handle_message data
    #  end

    #  Signal.trap("INT")  { self.stop }
    #  Signal.trap("TERM") { self.stop }

    #  @client.start
    #end

    def stop
      puts "stopped"
      self.mailbox << nil
    end

    private

    def receive_message
      loop do
        data = receive {|msg| msg }
        @bot.handle_message data
      end
    end

    #def handle_message(data)
    #  msg = SlackBotSlim::Message.new data
    #  return unless msg.user_id

    #  puts "receive message: #{msg.text}"

    #  #TODO check type and call typed method

    #  @reactions[:dm].each do |(_, ptn, prc)|
    #    if matched = ptn.match(msg.text)
    #      msg.matched = matched
    #      prc.call msg
    #    end
    #  end

    #  @reactions[:ambient].each do |(_, ptn, prc)|
    #    if matched = ptn.match(msg.text)
    #      msg.matched = matched
    #      prc.call msg
    #    end
    #  end
    #rescue => ex
    #  puts "Exception in handle message : #{ex.message}"
    #  puts ex.backtrace.join("\n\t")
    #  send_message(
    #    channel: msg.channel_id,
    #    text: "error : '#{ex.message}'",
    #  )
    #end

    #def valid_type?(type)
    #  [:ambient, :dm, :mention].include? type
    #end
  end
end


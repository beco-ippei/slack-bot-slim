require 'slack'

Slack.configure do |config|
  config.token = ENV['token']
end

cmd = ARGV[0]
if cmd == 'auth_test'
  puts " --- #{cmd} ---------"
  p Slack.auth_test
  exit
end


client = Slack.realtime

client.on :hello do
  puts 'Successfully connected.'
end

client.on :message do |data|
  puts "receive message: #{data['text']}"
  case data['text']
  when /bot hi/ then
    reply data, "Hi <@#{data['user']}>!"
  when /^bot/ then
    reply data, "Sorry <@#{data['user']}>, what?"
  end
end

def api
  @@api ||= Slack::API.new
  @@api
end

def reply(data, msg)
  params = {
    channel: data['channel'],
    username: 'rubot',      #TODO
    icon_emoji: ':japanese_goblin:',
    text: msg,
  }
  api.chat_postMessage params
end

client.start


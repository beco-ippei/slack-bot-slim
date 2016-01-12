require 'slack-ruby-client'

Slack.configure do |config|
    config.token = ENV['token']
end

cmd = ARGV[0]
if cmd == 'auth_test'
  puts " --- #{cmd} ---------"
  p Slack.auth_test
  exit
end


client = Slack::RealTime::Client.new

client.on :hello do
  puts 'Successfully connected.'
end

client.on :message do |data|
  puts "receive message: #{data['text']}"
  case data['text']
  when /bot hi/ then
    client.message channel: data['channel'], text: "Hi <@#{data['user']}>!"
  when /^bot/ then
    client.message channel: data['channel'], text: "Sorry <@#{data['user']}>, what?"
  end
end

client.start!


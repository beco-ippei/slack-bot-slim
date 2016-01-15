require './lib/slack_bot_slim'

SlackBot.token = ENV['token']
#TODO: fetch name, icon by api.
SlackBot.name = ENV['name']
bot = SlackBot.generate

bot.hear :ambient, /hello/i do |msg|
  p msg
  msg.reply 'great !'
end

bot.hear :ambient, /bot hi/ do |msg|
  msg.reply "Hi <@#{msg.user}>!"
end

bot.hear :mention, /^bot/ do |msg|
  msg.reply "Sorry <@#{msg.user}>, what?"
end

bot.start_waiting


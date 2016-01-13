require './lib/slack_bot'

SlackBot.token = ENV['token']
bot = SlackBot.generate

bot.hear :ambient, /hello/i do |msg|
  p msg
  bot.reply msg, 'great !'
end

bot.hear :ambient, /bot hi/ do |msg|
  bot.reply msg, "Hi <@#{msg['user']}>!"
end

bot.hear :mention, /^bot/ do |msg|
  bot.reply msg, "Sorry <@#{msg['user']}>, what?"
end

bot.start_waiting


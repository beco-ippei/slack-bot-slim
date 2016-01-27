require './lib/slack_bot_slim'

SlackBot.token = ENV['token']
bot = SlackBot.instance

$LOAD_PATH.unshift File.expand_path('../app', __FILE__)

require 'application'

# start
bot.start


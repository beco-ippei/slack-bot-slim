require 'slack'

dir = File.expand_path('../slack_bot_slim', __FILE__)
Dir[File.join dir, '**', '*.rb'].each do |file|
  require file
end

SlackBot = SlackBotSlim::Bot


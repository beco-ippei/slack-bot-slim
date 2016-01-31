# Slack::Bot::Slim

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/slack/bot/slim`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'slack-bot-slim'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install slack-bot-slim


# TODO
* simple framework
  * pattern match handler
  * plugin with include-file (require ?)
  * plugin with rubygems (??
  * plugin with 'slack-snippets' (for ruby-study?)
* parse params
  * user-info
  * channel-info
  * message-info (like pattern matched blocks)
* ignore channel or user messages by config
  * white or black listing
  * by bot
  * by response (hear)


## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/slack-bot-slim.


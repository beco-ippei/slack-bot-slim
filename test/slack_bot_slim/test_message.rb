require 'minitest/autorun'
require './lib/slack_bot_slim/message'

describe SlackBotSlim::Message do
  before do
    @msg = SlackBotSlim::Message.new(
      'type': 'test',
      'text': 'text',
      'ts': Time.now.usec,
    )
  end

  describe "#parse_test" do
    it 'must not fetch mention' do
      text = 'test not mentioned'
      exp = {dm: nil, text: text}
      @msg.send(:parse_text, text).must_equal exp
    end

    it 'must fetch direct mention' do
      _uid = 'ABCDEF'
      _txt = 'direct mentioned'
      text = "<@#{_uid}>: #{_txt} "
      exp = {dm: _uid, text: _txt}
      @msg.send(:parse_text, text).must_equal exp
    end
  end
end


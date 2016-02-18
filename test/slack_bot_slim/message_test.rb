require 'test_helper'

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
      exp = {dm: nil, mentions: [], text: text}
      @msg.send(:parse_text, text).must_equal exp
    end

    it 'must fetch direct mention' do
      _uid = 'ABCDEF'
      _txt = 'direct mentioned'
      text = "<@#{_uid}>: #{_txt} "
      exp = {dm: _uid, mentions: [], text: _txt}
      @msg.send(:parse_text, text).must_equal exp
    end

    # case: direct mention
    # case: has mention(s)
    it 'must fetch mentions' do
      _uid = 'ABCDEF'
      _ids = %w[GHIJ KLMN OPQRSTU]
      _txt = 'direct mentioned and has mentions'

      id_txt = _ids.map{|e| "<@#{e}>"}.join(' ')
      exp_txt = "#{id_txt} #{_txt}"

      text = "<@#{_uid}>: #{id_txt} #{_txt}"
      exp = {dm: _uid, mentions: _ids, text: exp_txt}
      @msg.send(:parse_text, text).must_equal exp
    end

    # case: has multi-byte space char
    # TODO: can use 'context' ?
  end
end


# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slack_bot_slim/version'

Gem::Specification.new do |spec|
  spec.name          = "slack-bot-slim"
  spec.version       = SlackBotSlim::VERSION
  spec.authors       = ["beco-ippei"]
  spec.email         = ["beco.ippei@gmail.com"]

  spec.summary       = %q{light-weight slack bot rubygem.}
  spec.description   = <<-DESC
  A ruby slack-bot. Ligith-weight and simple (or should debug in use).
  ...
  DESC
  spec.homepage      = "https://github.com/beco-ippei/slack-bot-slim"
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "slack-api", "~> 1.2"
  spec.add_dependency "faye-websocket", "~> 0.9"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end

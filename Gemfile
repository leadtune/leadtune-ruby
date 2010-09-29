# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

source :gemcutter

group :development do
  unless RUBY_PLATFORM == "java"
    case RUBY_VERSION
    when /^1.9.2/
      gem "ruby-debug19"
    when /^1.8/
      gem "ruby-debug"
    end
  end
  gem "rake"
  gem "rdoc"
  gem "rspec", "2.0.0.beta.19"
  gem "rspec-core", "2.0.0.beta.19"
  gem "rspec-expectations", "2.0.0.beta.19"
  gem "rspec-mocks"
  gem "tcpsocket-wait"
  gem "webmock", :git => "http://github.com/phiggins/webmock.git"
end

gem "json"
gem "curb"

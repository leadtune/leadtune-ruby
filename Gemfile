source :gemcutter

gem "rake"
gem "cucumber"
gem "rspec"
gem "rdoc"
gem "rspec-core"
gem "rspec-expectations"
gem "rspec-mocks"
gem "json", "1.4.3"
gem "activemodel"
gem "curb-fu"
gem "rack"

unless RUBY_PLATFORM == "java"
  case RUBY_VERSION
  when /^1.9.2/
    gem "ruby-debug19"
  when /^1.8/
    gem "ruby-debug"
  end
end
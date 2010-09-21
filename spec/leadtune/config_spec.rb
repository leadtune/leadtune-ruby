# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

require "spec_helper"

describe Leadtune::Config do
  before(:each) {teardown_initializer}
  after(:each) {teardown_initializer}

  it "reads environment from APP_ENV" do
    ENV["APP_ENV"] = "production"

    subject.environment.should == :production

    ENV.delete("APP_ENV")
  end

  context("can set") do
    it "password" do
      Leadtune::Config.password = "secret"

      Leadtune::Config.new.password.should == "secret"
    end

    it "username" do
      Leadtune::Config.username = "bob"

      Leadtune::Config.new.username.should == "bob"
    end

    it "timeout" do
      Leadtune::Config.timeout = 5

      Leadtune::Config.new.timeout.should == 5
    end

    it "organization" do
      Leadtune::Config.organization = "ORG"

      Leadtune::Config.new.organization.should == "ORG"
    end

    it "leadtune_host" do
      Leadtune::Config.leadtune_host = "http://bad_url_for_test"

      Leadtune::Config.new.leadtune_host.should == "http://bad_url_for_test"
    end
  end
end

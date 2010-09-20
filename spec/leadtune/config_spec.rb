# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

require "spec_helper"

class Leadtune::Config
  def self.reset_class_vars
    @@timeout = nil
    @@organization = nil
    @@username = nil
    @@password = nil
  end
end

describe Leadtune::Config do
  before(:each) {Leadtune::Config.reset_class_vars}
  after(:each) {Leadtune::Config.reset_class_vars}

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
  end
end

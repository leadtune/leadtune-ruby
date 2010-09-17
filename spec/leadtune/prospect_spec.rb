# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

require "digest"
require "json"
require "spec_helper"

describe Leadtune::Prospect do

  subject do 
    Leadtune::Prospect.new({"prospect_id" => "deadfish",
                            "email" => "bar@baz.com",
                            "target_buyers" => ["AcmeU", "Bravo", "ConvU",],
                            "event" => "offers_prepared",}) do |p|
      # use ||= so we won't override if loaded from ENV or config_file
      p.organization ||= "Foo"
    end
  end

  context("w/ organization from config_file") do
    subject do
      Leadtune::Prospect.new(leadtune_config_file)
    end

    describe "#organization" do
      specify {subject.organization.should == "config_file_org"}
    end
  end

  context("when presented with an unrecognized factor") do
    it "creates a setter and a getter by that name" do
      fail "getter already exists" if subject.respond_to?(:my_new_factor)
      fail "setter already exists" if subject.respond_to?(:my_new_factor=)

      subject.my_new_factor = 5

      subject.should respond_to(:my_new_factor=)
      subject.should respond_to(:my_new_factor)
      subject.my_new_factor.should == 5
    end
  end
  
  context("w/ organization from ENV") do
    before(:all) do
      setup_leadtune_env
    end

    after(:all) do
      teardown_leadtune_env
    end

    subject {Leadtune::Prospect.new}
    
    describe "#organization" do
      specify {subject.organization.should == "env_org"}
    end
  end

  context("w/ organization from ENV *AND* config_file") do

    before(:all) do
      setup_leadtune_env
    end

    after(:all) do
      teardown_leadtune_env
    end

    subject {Leadtune::Prospect.new(leadtune_config_file)}

    describe "#organization" do
      it "uses the ENV value over the config file" do
        subject.organization.should == "env_org"
      end
    end
  end

  describe "#get" do
    before(:each) do
      stub_request(:any, /.*leadtune.*/).to_return(:body => fake_curb_response)
    end

    it "loads the browser_family factor" do
      subject.get

      subject.browser_family.should == "Firefox"
    end

  end

  describe "#post_body" do
    before(:each) do
      # requests are stubbed by json_factors_should_include
    end

    it "includes decision" do
      expected_factors = {"decision" => subject.decision,}

      subject.post_data.should include(expected_factors)
    end
  end

  describe("#new") do
    it "receives options in a Hash" do
      s = Leadtune::Prospect.new({:channel => "banner",})

      s.channel.should == "banner"
    end

    it "accepts a config_file as its (optional) first argument" do
      s = Leadtune::Prospect.new(leadtune_config_file, {:channel => "banner",})

      s.channel.should == "banner"
      s.organization.should == "config_file_org"
    end
  end

  describe("#target_buyers=") do
    it "is represented in the decision field of the JSON post body" do
      subject.target_buyers = ["foo",]
      json_factors_should_include({"decision" => {"target_buyers" => ["foo"]}})

      subject.post
    end

    it "raises ArgumentError when called with a non-Array" do
      lambda {subject.target_buyers = "foo"}.should raise_error(ArgumentError)
    end
  end


  private

  def json_factors_should_include(expected_factors)
    stub_request(:any, /.*leadtune.*/).to_return do |req|
      json = JSON::parse(req.body)
      json.should include(expected_factors)
      {:body => req.body, :status => [201, "Created"]}
    end
  end

  def fake_curb_response
    {:event => "offers_prepared",
     :organization => "LOL",
     :created_at => Time.now,
     :browser_family => "Firefox",
     :browser_version => "3.6.3",
     :email_hash => "deadbeef",
     :decision => {
       :appraisals => [{:target_buyer => "TB-LOL", :value => 1},],
     },
     :prospect_id => "deadbeef",}.to_json
  end
end

require "digest"
require "rack"
require "spec_helper"
require "tcpsocket-wait"
require "tempfile"

describe Leadtune::Seller do

  before(:each) do
    subject.event = "offers_prepared"
    subject.organization = "Foo"
    subject.decision = {"target_buyers" => ["AcmeU", "Bravo", "ConvU",],}
    subject.email = "bar@baz.com"
    # use ||= so we won't override if loaded from ENV or config_file
    subject.username ||= "test@foo.com"
    subject.password ||= "secret"
  end

  it "has valid defaults" do
    subject.should be_valid
  end

  ["decision", "event", "organization", "username", "password",].each do |field|
    it "should be invalid without an #{field}" do
      subject.send("#{field}=", nil)

      subject.should_not be_valid
      subject.errors[field].should_not be_empty
    end
  end

  it "should be invalid without either an email or an email_hash" do
    subject.email = subject.email_hash = nil

    subject.should_not be_valid
    subject.errors[:base].any? {|x| /email or email_hash/ === x}.should be_true
  end

  it "should be valid with an email_hash in place of an email" do
    # NOTE: This is *not* how email_hash's are computed in production
    subject.email_hash = Digest::SHA1.hexdigest(subject.email)
    subject.email = nil

    subject.should be_valid
  end

  context("w/ username & password from config_file") do
    subject do
      config_file = StringIO.new <<EOF
username: config_file@config_file.com
password: config_file_secret
EOF
      Leadtune::Seller.new(config_file)
    end

    describe "#username" do
      specify {subject.username.should == "config_file@config_file.com"}
    end

    describe "#password" do
      specify {subject.password.should == "config_file_secret"}
    end
  end

  context("w/ username & password from ENV") do

    before(:all) do
      ENV["LEADTUNE_SELLER_USERNAME"] = "env@env.com"
      ENV["LEADTUNE_SELLER_PASSWORD"] = "env_secret"
    end

    after(:all) do
      ENV.delete("LEADTUNE_SELLER_USERNAME")
      ENV.delete("LEADTUNE_SELLER_PASSWORD")
    end

    subject {Leadtune::Seller.new}

    describe "#username" do
      specify {subject.username.should == "env@env.com"}
    end

    describe "#password" do
      specify {subject.password.should == "env_secret"}
    end
  end

  context("w/ username & password from ENV *AND* config_file") do

    before(:all) do
      ENV["LEADTUNE_SELLER_USERNAME"] = "env@env.com"
      ENV["LEADTUNE_SELLER_PASSWORD"] = "env_secret"
    end

    after(:all) do
      ENV.delete("LEADTUNE_SELLER_USERNAME")
      ENV.delete("LEADTUNE_SELLER_PASSWORD")
    end

    subject do
      config_file = StringIO.new <<EOF
username: config_file@config_file.com
password: config_file_secret
EOF
      Leadtune::Seller.new(config_file)
    end

    describe "#username" do
      it "should use the ENV value over the config file" do
        subject.username.should == "env@env.com"
      end
    end

    describe "#password" do
      it "should use the ENV value over the config file" do
        subject.password.should == "env_secret"
      end
    end
  end

  context("decision") do
    it "must not be empty" do 
      subject.decision = {}

      subject.should_not be_valid
      subject.errors["decision"].should_not be_empty
    end

    context("\"target_buyers\" key") do
      it "should be valid" do 
        subject.decision = {"target_buyers" => ["bar", "baz",],}

        subject.should be_valid
      end

      it "must exist" do 
        subject.decision = {"foo" => ["bar", "baz"]}

        subject.should_not be_valid
        subject.errors["decision"].should_not be_empty
      end

      it "must be enumerable" do 
        subject.decision = {"target_buyer" => 0}

        subject.should_not be_valid
        subject.errors["decision"].should_not be_empty
      end
    end
  end

  describe "#factors" do
    specify {subject.factors.should include("organization")}
    specify {subject.factors.should include("browser_family")}
    specify {subject.factors.should include("browser_version")}
  end

  it "rejects undefined factors" do
    lambda do
      subject.my_factor = "foo"
    end.should raise_error(NoMethodError, /my_factor=/)
  end

  describe "#post" do
    it "converts required factors to JSON" do
      expected_factors = {"event" => subject.event,
                          "organization" => subject.organization,
                          "decision" => subject.decision,}
      json_factors_should_include(expected_factors)

      subject.post
    end

    it "converts optional factors to JSON" do
      subject.channel = "banner"
      expected_factors = {"channel" => subject.channel,}
      json_factors_should_include(expected_factors)

      subject.post
    end

    it "times out after x seconds" do
      stub_request(:post, "https://sandbox-appraiser.leadtune.com/prospects").to_timeout

      lambda {subject.post}.should raise_error(Curl::Err::TimeoutError)
    end
  end


  private


  def json_factors_should_include(expected_factors)
    stub_request(:post, "https://sandbox-appraiser.leadtune.com/prospects").
      to_return do |req|
      json = JSON::parse(req.body)
      json.should include(expected_factors)
      {:body => req.body}
    end
  end

end

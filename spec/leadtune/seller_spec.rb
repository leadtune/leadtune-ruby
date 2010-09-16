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


  context("is valid") do
    it "with before(:each) defaults" do
      subject.should be_valid
    end

    it "with an email_hash in place of an email" do
      # NOTE: This is *not* how email_hash's are computed in production
      subject.email_hash = Digest::SHA1.hexdigest(subject.email)
      subject.email = nil

      subject.should be_valid
    end
  end

  context("is invalid") do
    ["decision", "event", "organization", "username", "password",].each do |field|
      it "without a(n) #{field}" do
        subject.send("#{field}=", nil)

        subject.should_not be_valid
        subject.errors[field].should_not be_empty
      end
    end

    it "without either an email or an email_hash" do
      subject.email = subject.email_hash = nil

      subject.should_not be_valid
      subject.errors[:base].any? {|x| /email or email_hash/ === x}.should be_true
    end
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
      it "uses the ENV value over the config file" do
        subject.username.should == "env@env.com"
      end
    end

    describe "#password" do
      it "uses the ENV value over the config file" do
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
    before(:each) do
      # requests are stubbed by json_factors_should_include
    end

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

    ["401", "404", "500"].each do |code|
      context("when a #{code} is returned") do
        before(:each) do
          stub_request(:any, /.*leadtune.*/).to_return(:status => code.to_i)
        end

        it "raises a HttpError" do
          pending "webmock allowing Curb callbacks" do
            lambda {subject.post}.should raise_error(Leadtune::Seller::HttpError)
          end
        end
      end
    end
  end

  describe("#timeout") do
    it "is passed on to Curl::Easy" do
      curl = double(Curl::Easy, :body_str => "{}").as_null_object
      curl.should_receive(:timeout=).with(5)
      Curl::Easy.stub!(:new).and_yield(curl).and_return(curl)
      stub_request(:post, "https://sandbox-appraiser.leadtune.com/prospects").
        to_return(:status => [201, "Created"])

      subject.post
    end

    context("by default") do
      it "is 5" do
        subject.timeout.should == 5
      end
    end

    context("with timeout of 6 in ENV value") do
      before(:all) do
        ENV["LEADTUNE_SELLER_TIMEOUT"] = "6"
      end

      after(:all) do
        ENV.delete("LEADTUNE_SELLER_TIMEOUT")
      end

      it "is 6" do
        subject.timeout.should == 6
      end
    end

    context("with timeout of 7 in config_file") do
      subject do
        config_file = StringIO.new <<EOF
timeout: 7
EOF
        Leadtune::Seller.new(config_file)
      end

      it "is 7" do
        subject.timeout.should == 7
      end
    end

  end

  describe("#new") do
    
    it "receives options in a Hash" do
      s = Leadtune::Seller.new({:channel => "banner",})

      s.channel.should == "banner"
    end

    it "silently ignores undefined factors in a Hash" do
      s = Leadtune::Seller.new({:bad_factor => "muahahaha!",})

      s.should_not respond_to(:bad_factor)
    end

    it "accepts a config_file as its (optional) first argument" do
      cf = StringIO.new <<EOF
username: foo
password: bar
EOF
      s = Leadtune::Seller.new(cf, {:channel => "banner",})

      s.channel.should == "banner"
      s.username.should == "foo"
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

end

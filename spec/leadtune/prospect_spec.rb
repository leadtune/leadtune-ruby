require "digest"
require "spec_helper"

describe Leadtune::Prospect do

  subject do 
    Leadtune::Prospect.new({"event" => "offers_prepared",
                            "target_buyers" => ["AcmeU", "Bravo", "ConvU",],
                            "email" => "bar@baz.com",}) do |p|
      # use ||= so we won't override if loaded from ENV or config_file
      p.username ||= "test@foo.com"
      p.password ||= "secret"
      p.organization ||= "Foo"
    end
  end

  context("w/ username, password, & organization from config_file") do
    subject do
      Leadtune::Prospect.new(leadtune_config_file)
    end

    describe "#username" do
      specify {subject.username.should == "config_file@config_file.com"}
    end

    describe "#password" do
      specify {subject.password.should == "config_file_secret"}
    end

    describe "#organization" do
      specify {subject.organization.should == "config_file_org"}
    end
  end

  context("w/ username, password, & organization from ENV") do

    before(:all) do
      setup_leadtune_env
    end

    after(:all) do
      teardown_leadtune_env
    end

    subject {Leadtune::Prospect.new}

    describe "#username" do
      specify {subject.username.should == "env@env.com"}
    end

    describe "#password" do
      specify {subject.password.should == "env_secret"}
    end

    describe "#organization" do
      specify {subject.organization.should == "env_org"}
    end
  end

  context("w/ username, password, & organization from ENV *AND* config_file") do

    before(:all) do
      setup_leadtune_env
    end

    after(:all) do
      teardown_leadtune_env
    end

    subject do
      Leadtune::Prospect.new(leadtune_config_file)
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

    describe "#organization" do
      it "uses the ENV value over the config file" do
        subject.organization.should == "env_org"
      end
    end
  end

  describe "#availble_factors" do
    subject {Leadtune::Prospect.new.available_factors}

    it {should_not include("decision")}
    it {should include("browser_family")}
    it {should include("browser_version")}
    it {should include("organization")}
  end

  it "rejects undefined factors" do
    lambda do
      subject.my_factor = "foo"
    end.should raise_error(NoMethodError, /my_factor=/)
  end

  describe "#get" do
    before(:each) do
      stub_request(:any, /.*leadtune.*/).to_return(:body => fake_curb_response)
      subject.instance_variable_set("@method", "GET")
      subject.prospect_id = "deadfish"
    end

    it "loads the browser_family factor" do
      subject.get

      subject.browser_family.should == "Firefox"
    end

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

        it "raises a LeadtuneError" do
          pending "webmock allowing Curb callbacks" do
            lambda {subject.post}.should raise_error(Leadtune::LeadtuneError)
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
        ENV["LEADTUNE_TIMEOUT"] = "6"
      end

      after(:all) do
        ENV.delete("LEADTUNE_TIMEOUT")
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
        Leadtune::Prospect.new(config_file)
      end

      it "is 7" do
        subject.timeout.should == 7
      end
    end

  end

  describe("#new") do
    
    it "receives options in a Hash" do
      s = Leadtune::Prospect.new({:channel => "banner",})

      s.channel.should == "banner"
    end

    it "silently ignores undefined factors in a Hash" do
      s = Leadtune::Prospect.new({:bad_factor => "muahahaha!",})

      s.should_not respond_to(:bad_factor)
    end

    it "accepts a config_file as its (optional) first argument" do
      cf = StringIO.new <<EOF
username: foo
password: bar
EOF
      s = Leadtune::Prospect.new(cf, {:channel => "banner",})

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

  def setup_leadtune_env
    ENV["LEADTUNE_USERNAME"] = "env@env.com"
    ENV["LEADTUNE_PASSWORD"] = "env_secret"
    ENV["LEADTUNE_ORGANIZATION"] = "env_org"
  end

  def teardown_leadtune_env
    ENV.delete("LEADTUNE_USERNAME")
    ENV.delete("LEADTUNE_PASSWORD")
    ENV.delete("LEADTUNE_ORGANIZATION")
  end

  def leadtune_config_file
    StringIO.new <<EOF
username: config_file@config_file.com
password: config_file_secret
organization: config_file_org
EOF
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

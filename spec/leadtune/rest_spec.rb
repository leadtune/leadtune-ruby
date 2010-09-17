require "spec_helper"

describe Leadtune::Rest do

  subject {Leadtune::Rest.new(Leadtune::Config.new)}

  context("w/ username & password from config_file") do

    subject {Leadtune::Rest.new(rest_config)}

    before(:each) do
      @curl_easy = null_curl_easy
    end

    describe "#username" do
      it "uses the config_file value" do
        @curl_easy.should_receive(:username=).with("config@config.com")

        subject.get(null_prospect)
      end
    end

    describe "#password" do
      it "uses the config_file value" do
        @curl_easy.should_receive(:password=).with("config_secret")

        subject.get(null_prospect)
      end
    end
  end

  context("w/ username & password from ENV") do
    before(:all) do
      setup_leadtune_env
    end

    after(:all) do
      teardown_leadtune_env
    end

    before(:each) do
      @curl_easy = null_curl_easy
    end

    describe "#username" do
      it "uses the ENV value" do
        @curl_easy.should_receive(:username=).with("env@env.com")
        
        subject.get(null_prospect)
      end
    end

    describe "#password" do
      it "uses the ENV value" do
        @curl_easy.should_receive(:password=).with("env_secret")
        
        subject.get(null_prospect)
      end
    end
  end

  context("w/ username & password from ENV *AND* config_file") do

    subject {Leadtune::Rest.new(rest_config)}

    before(:all) do
      setup_leadtune_env
    end

    after(:all) do
      teardown_leadtune_env
    end

    before(:each) do
      @curl_easy = null_curl_easy
    end

    describe "#username" do
      it "uses the ENV value over the config file" do
        @curl_easy.should_receive(:username=).with("env@env.com")

        subject.get(null_prospect)
      end
    end

    describe "#password" do
      it "uses the ENV value over the config file" do
        @curl_easy.should_receive(:password=).with("env_secret")

        subject.get(null_prospect)
      end
    end
  end

  describe "#post" do
    before(:each) do
      # requests are stubbed by json_factors_should_include
    end

    # it "converts required factors to JSON" do
    #   expected_factors = {"event" => subject.event,
    #                       "organization" => subject.organization,
    #                       "decision" => subject.decision,}
    #   json_factors_should_include(expected_factors)

    #   subject.post(null_prospect)
    # end

    # it "converts optional factors to JSON" do
    #   subject.channel = "banner"
    #   expected_factors = {"channel" => subject.channel,}
    #   json_factors_should_include(expected_factors)

    #   subject.post(null_prospect)
    # end

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
    before(:each) do
      @curl_easy = null_curl_easy
    end

    it "is passed on to Curl::Easy" do
      @curl_easy.should_receive(:timeout=).with(5)

      subject.get(null_prospect)
    end

    context("by default") do
      it "is 5" do
        @curl_easy.should_receive(:timeout=).with(5)

        subject.get(null_prospect)
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
        @curl_easy.should_receive(:timeout=).with(6)

        subject.get(null_prospect)
      end
    end

    context("with timeout of 7 in config_file") do
      subject {Leadtune::Rest.new(rest_config)}

      it "is 7" do
        @curl_easy.should_receive(:timeout=).with(7)

        subject.get(null_prospect)
      end
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

  def null_prospect
    double(Leadtune::Prospect, :prospect_id => "deadbeef").as_null_object
  end

  def null_curl_easy
    curl_easy = double(Curl::Easy, :body_str => "{}").as_null_object
    Curl::Easy.stub!(:new).and_yield(curl_easy).and_return(curl_easy)
    curl_easy
  end

  def rest_config
    config_file = StringIO.new <<EOF
username: config@config.com
password: config_secret
timeout: 7
EOF
    Leadtune::Config.new(config_file)
  end
end

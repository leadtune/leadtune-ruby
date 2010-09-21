# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

require "tempfile"
require "webrick"
require "tcpsocket-wait"

require "spec_helper"

describe Leadtune::Rest do

  subject {Leadtune::Rest.new(Leadtune::Config.new)}

  context("w/ username and password from initializer") do

    before(:each) do
      @curl_easy = null_curl_easy
      setup_initializer
    end

    after(:each) do
      teardown_initializer
    end

    describe "#username" do
      it "uses the initializer value" do
        @curl_easy.should_receive(:username=).with("init_user")

        subject.get(mock_post_data)
      end
    end

    describe "#password" do
      it "uses the initializer value" do
        @curl_easy.should_receive(:password=).with("init_secret")

        subject.get(mock_post_data)
      end
    end
  end


  describe "#post (slow)" do

    before(:all) {WebMock.allow_net_connect!}
    after(:all) {WebMock.disable_net_connect!}

    ["401", "404", "500"].each do |code|
      context("when a #{code} is returned") do
        it "raises a LeadtuneError" do
          mock_server(code) do
            lambda {subject.post(mock_post_data)}.should raise_error(Leadtune::LeadtuneError)
          end
        end
      end
    end
  end

  describe("#timeout") do
    before(:each) do
      @curl_easy = null_curl_easy
    end

    context("by default") do
      it "is 5" do
        @curl_easy.should_receive(:timeout=).with(5)

        subject.get(mock_post_data)
      end
    end

    context("with timeout of 7 in initializer") do
      before(:each) do
        setup_initializer
      end

      after(:each) do
        teardown_initializer
      end

      it "is 7" do
        @curl_easy.should_receive(:timeout=).with(7)

        subject.get(mock_post_data)
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

  def mock_post_data
    {"prospect_id" => "deadbeef",}
  end

  def null_curl_easy
    curl_easy = double(Curl::Easy, :body_str => "{}").as_null_object
    Curl::Easy.stub!(:new).and_yield(curl_easy).and_return(curl_easy)
    curl_easy
  end

  def mock_server(code, &block)
    quietly do
      server = WEBrick::HTTPServer.new(:Port => THREADED_MOCK_SERVER_PORT)
      server.mount_proc("/prospects") do |req, res|
        res.body = "mock_server"
        res.status = code
      end

      thread = Thread.new(server) {|s| s.start}

      TCPSocket.wait_for_service_with_timeout({:host => "localhost", 
                                               :port => THREADED_MOCK_SERVER_PORT,
                                               :timeout => 10})
      block.call
      server.shutdown
      thread.join
    end
  end

  def quietly(&block)
    old_stdout = old_stderr = nil

    Tempfile.open("seller_spec") do |tf|
      old_stdout, $stdout = $stdout, tf
      old_stderr, $stderr = $stderr, tf
      block.call(tf)
    end
    
    $stdout, $stderr = old_stdout, old_stderr
  end

  THREADED_MOCK_SERVER_PORT = 9292
end

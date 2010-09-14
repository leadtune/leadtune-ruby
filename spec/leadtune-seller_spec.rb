require "spec_helper"
require "rack"

describe Leadtune::Seller::Base do
  before(:each) do
    factors_path = "/Users/ewollesen/src/uber/site/db/factors.yml"
    Leadtune::Seller::Base.load_factors(File.open(factors_path))
  end

  describe "#post" do

    before(:each) do
      subject.event = "offers_prepared"
      subject.organization = "Foo"
      subject.decision = {"target_buyers" => ["AcmeU", "Bravo", "ConvU",],}
      subject.email = "foo@bar.com"
    end

    def body_server
      proc {|env| [200, {}, env["rack.input"].read]}
    end

    ["event", "organization", "decision"].each do |field|
      it "should require a(n) #{field}" do
        subject.send("#{field}=", nil)
        subject.should_not be_valid
      end
    end

    it "should require an email or an email_hash" do
      subject.email = subject.email_hash = nil
      subject.should_not be_valid
    end

    it "should convert factors to JSON" do
      CurbFu.stubs = {"sandbox-appraiser.leadtune.com" => body_server}
      post_body = JSON::parse(subject.post.body)
      ["event", "organization", "decision"].each do |key|
        post_body.should include(key), post_body
      end
    end

    it "should pass on additional factors" do
      CurbFu.stubs = {"sandbox-appraiser.leadtune.com" => body_server}
      subject.channel = "banner"
      post_body = JSON::parse(subject.post.body)
      post_body.should include("channel"), post_body
    end

    it "should not accept undefined factors" do
      lambda do
        subject.my_factor = "foo"
      end.should raise_error(NoMethodError, /my_factor=/)
    end
  end
end

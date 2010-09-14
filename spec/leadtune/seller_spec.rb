require "spec_helper"
require "rack"

describe Leadtune::Seller do
  describe "#post" do

    before(:each) do
      subject.event = "offers_prepared"
      subject.organization = "Foo"
      subject.decision = {"target_buyers" => ["AcmeU", "Bravo", "ConvU",],}
      subject.email = "foo@bar.com"
    end

    def mock_server(&block)
      proc do |env|
        body = env["rack.input"].read
        yield(JSON::parse(body)) if block_given?
        [200, {}, body,]
      end
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
      CurbFu.stubs = {"sandbox-appraiser.leadtune.com" => mock_server do |body|
          ["event", "organization", "decision"].each do |key|
            body.should include(key), body
          end
        end
      }
    end

    it "should pass on additional factors" do
      CurbFu.stubs = {"sandbox-appraiser.leadtune.com" => mock_server do |body|
          body.should include("channel"), body
        end
      }
    end

    it "should not accept undefined factors" do
      lambda do
        subject.my_factor = "foo"
      end.should raise_error(NoMethodError, /my_factor=/)
    end
  end
end

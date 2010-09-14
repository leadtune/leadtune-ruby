require "digest"
require "rack"
require "spec_helper"

describe Leadtune::Seller do

  before(:each) do
    subject.event = "offers_prepared"
    subject.organization = "Foo"
    subject.decision = {"target_buyers" => ["AcmeU", "Bravo", "ConvU",],}
    subject.email = "bar@baz.com"
    subject.username = "test@foo.com"
    subject.password = "secret"
  end

  def mock_server(&block)
    proc do |env|
      body = env["rack.input"].read
      yield(JSON::parse(body)) if block_given?
      [200, {}, body,]
    end
  end

  it "should be valid" do
    subject.should be_valid
  end

  ["decision", "event", "organization",].each do |field|
    it "should be invalid without an #{field}" do
      subject.send("#{field}=", nil)

      subject.should_not be_valid
    end
  end

  it "should be invalid without either an email or an email_hash" do
    subject.email = subject.email_hash = nil

    subject.should_not be_valid
  end

  it "should be valid with an email_hash in place of an email" do
    # NOTE: This is *not* how email_hash's are computed in production
    subject.email_hash = Digest::SHA1.hexdigest(subject.email)
    subject.email = nil

    subject.should be_valid
  end

  context("decision") do
    it "must not be empty" do 
      subject.decision = {}

      subject.should_not be_valid
    end

    context("\"target_buyers\" key") do
      it "should be valid" do 
        subject.decision = {"target_buyers" => ["bar", "baz",],}

        subject.should be_valid, "foo #{subject.valid?}"
      end

      it "must exist" do 
        subject.decision = {"foo" => ["bar", "baz"]}

        subject.should_not be_valid
      end

      it "must be enumerable" do 
        subject.decision = {"target_buyer" => 0}

        subject.should_not be_valid
      end
    end
  end

  it "should not accept undefined factors" do
    lambda do
      subject.my_factor = "foo"
    end.should raise_error(NoMethodError, /my_factor=/)
  end

  describe "#post" do
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
  end
end

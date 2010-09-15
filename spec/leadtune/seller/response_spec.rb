require "spec_helper"
require "rack"

describe Leadtune::Seller::Response do
  subject {Leadtune::Seller::Response.new(fake_curb_response)}

  context("responds to") do
    expected_methods = ["browser_name", "created_at", "decision",
                        "email_hash", "event", "organization", "prospect_id",]

    expected_methods.each do |name|
      it "##{name}" do
        subject.should respond_to(name)
      end
    end
  end

  describe "#appraisals" do
    subject {Leadtune::Seller::Response.new(fake_curb_response).appraisals}
    it {should_not be_empty}

    it "lists non-duplicates" do
      subject.non_duplicates.should include({"target_buyer" => "TB-LOL", "value" => 1})
    end
  end

  describe "#event" do
    subject {Leadtune::Seller::Response.new(fake_curb_response).event}
    it {should == "offers_prepared"}
  end

  describe "#factors" do
    subject {Leadtune::Seller::Response.new(fake_curb_response).factors}

    it {should_not include("decision")}
    it {should include("browser_name")}
  end


  private

  def fake_curb_response
    mock(:body => {:event => "offers_prepared",
                   :organization => "LOL",
                   :created_at => Time.now,
                   :browser_name => "Firefox",
                   :email_hash => "deadbeef",
                   :decision => {
                     :appraisals => [{:target_buyer => "TB-LOL", :value => 1},],
                   },
                   :prospect_id => "deadbeef",}.to_json)
  end

end

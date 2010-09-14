require "spec_helper"
require "rack"

describe Leadtune::Seller::Response do
  subject {Leadtune::Seller::Response.new(fake_curb_response)}

  [:email_hash, :decision, :prospect_id, :organization, :event, :created_at].each do |name|
    it "should have an #{name} method" do
      subject.respond_to?(name).should be_true
    end
  end

  it "should have an appraisal" do
    subject.appraisals.size.should == 1
  end

  it "should have an event of \"offers_prepared\"" do
    subject.event.should == "offers_prepared"
  end


  private

  def fake_curb_response
    mock(:body => {:event => "offers_prepared",
                   :organization => "LOL",
                   :created_at => Time.now,
                   :email_hash => "deadbeef",
                   :decision => {
                     :appraisals => [{:target_buyer => "TB-LOL", :value => 1},],
                   },
                   :prospect_id => "deadbeef",}.to_json)
  end

end

# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

require "spec_helper"

describe Leadtune::Appraisals do

  subject do 
    Leadtune::Appraisals.new([{"target_buyer" => "AcmeU", "value" => 1},
                              {"target_buyer" => "Bravo", "value" => 0},])
  end

  describe("#non_duplicates") do
    it "includes target buyers to whom the prospect is not a duplicate" do
      subject.non_duplicates.should include({"target_buyer" => "AcmeU", "value" => 1})
    end

    it "excludes target buyers to whom the prospect is a duplicate" do
      subject.non_duplicates.should_not include({"target_buyer" => "Bravo", "value" => 0})
    end
  end

end

# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

# Extends Array by adding a few convenience methods for find duplicate,
# or non-duplicate appraisals.
class Leadtune::Appraisals < Array
  def non_duplicates
    find_all {|a| 0 < a["value"]}
  end

  def duplicates
    find_all {|a| 0 == a["value"]}
  end
end

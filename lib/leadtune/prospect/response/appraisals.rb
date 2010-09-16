# Extends Array by adding a few convenience methods for find duplicate,
# or non-duplicate appraisals.
class Appraisals < Array
  def non_duplicates
    find_all {|a| 0 < a["value"]}
  end

  def duplicates
    find_all {|a| 0 == a["value"]}
  end
end

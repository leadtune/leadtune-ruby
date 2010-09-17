class Array
  # stolen from ActiveSupport
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
end

class Object
  def present?
    case self
    when String
      !empty? && !nil?
    when Hash
      !empty?
    when NilClass
      false
    else
      raise RuntimeError.new("Not handled: #{self.class}")
    end
  end
end

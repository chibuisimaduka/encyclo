module Recursively

  def recursively(initial, &block)
    initial.blank? ? nil : recursively(yield(initial))
  end

  def each_recursively(initial, &block)
    return nil if initial.blank?

    val = yield(initial)
    return nil if val.blank?
    val.is_a?(Array) ? val.each {|v| recursively(v)} : recursively(v)
  end

end

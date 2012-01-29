module PredicatesHelper
  def dash_if_blank
    value.blank? ? "-" : value
  end
end

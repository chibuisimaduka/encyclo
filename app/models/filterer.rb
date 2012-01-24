class Filterer

  attr_reader :filter_attributes

  FILTERS = [:language_id, :document_type_id]
   
  FILTERS.each do |filter|
    define_method(filter) do
      @filter_attributes[filter.to_s]
    end
    define_method("#{filter}=") do |value|
      value.blank? ? @filter_attributes.delete(filter.to_s) : @filter_attributes[filter.to_s] = value
    end
  end

  def initialize
    @filter_attributes = {}
  end

  def update_attributes(attrs)
    @filter_attributes.merge!(attrs)
    @filter_attributes.delete_if {|k,v| v.blank? }
  end

end

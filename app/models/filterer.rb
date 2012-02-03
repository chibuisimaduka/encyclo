class Filterer

  attr_reader :attributes, :filters

  def initialize(*filters)
    @attributes = {}
    @filters = filters.map(&:to_sym)
  end

  def method_missing(method_name, *args)
    if method_name[-1] == "="
      super unless @filters.include?(method_name[0..-2].to_sym)
      raise "Wrong number of arguments for setter #{method_name[0..-2]}" if args.size != 1
      @attributes[method_name[0..-2].to_sym] = args[0]
    else
      super unless @filters.include?(method_name.to_sym)
      @attributes[method_name.to_sym]
    end
  end

  def update_attributes(attrs)
    @attributes.merge!(attrs)
    @attributes.delete_if {|k,v| v.blank? }
  end

end

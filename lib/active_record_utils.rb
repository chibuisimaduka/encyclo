module ActiveRecordUtils

  # TODO: union

  # TODO: block should be the mandatory argument and parent_name optional
  def collect_all(parent_name, include_self=true, &block)
    parent = self.send(parent_name)
    if parent.is_a? Array
      values = include_self ? (block_given? ? yield(self) : self) : parent.blank? ? [] : (block_given? ? (parent.map {|p| yield(p)}) : parent)
      values = values.blank? ? [] : [values] unless values.is_a? Array
      return values if parent.blank?
      (parent.map do |p|
        p.collect_all(parent_name, include_self, &block)
      end).flatten
    else
      values = include_self ? (block_given? ? yield(self) : self) : parent.blank? ? [] : (block_given? ? yield(parent) : parent)
      values = values.blank? ? [] : [values] unless values.is_a? Array
      parent.blank? ? values : values + parent.collect_all(parent_name, include_self, &block)
    end
  end

  alias map_all collect_all

end

ActiveRecord::Base.send(:include, ActiveRecordUtils)

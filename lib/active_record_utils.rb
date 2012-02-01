module ActiveRecordUtils

  def collect_all(parent_name, include_self=true, &block)
    # FIXME: Should always be a block instead of column. &:name instead of :name
    parent = self.send(parent_name)
    values = include_self ? (block_given? ? yield(self) : self.send(parent_name)) : parent.blank? ? [] : (block_given? ? yield(parent) : parent.send(parent_name))
    values = values.blank? ? [] : [values] unless values.is_a? Array
    parent.blank? ? values : values + parent.collect_all(parent_name, include_self, &block)
  end

  alias map_all collect_all

end

ActiveRecord::Base.send(:include, ActiveRecordUtils)

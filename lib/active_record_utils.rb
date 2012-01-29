module ActiveRecordUtils

  def collect_all(parent_name, column=nil)
    parent = self.send(parent_name)
    values = column ? self.send(column) : self
    values = values.blank? ? [] : [values] unless values.is_a? Array
    parent.blank? ? values : values + parent.collect_all(parent_name, column)
  end

  alias map_all collect_all

end

ActiveRecord::Base.send(:include, ActiveRecordUtils)

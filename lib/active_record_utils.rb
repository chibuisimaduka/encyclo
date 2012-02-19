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

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    # The purpose of this method is the create the associated model at the same time.
    # Exemple: Entity.create_all names: [{value: "some name", possible_name_spellings: [spelling: "some name"]}]
    def create_all(attributes={})
      self.new Hash[attributes.map do |k,v|
        if v.is_a? Hash
          [k,self.name.constantize.reflect_on_association(k.to_sym).klass.create_all(v)]
        elsif v.is_a? Array
          [k,v.map { |vi| vi.is_a?(Hash) ? self.name.constantize.reflect_on_association(k.to_sym).klass.create_all(vi) : vi }]
        else
          [k,v]
        end
      end]
    end

  end

end

ActiveRecord::Base.send(:include, ActiveRecordUtils)

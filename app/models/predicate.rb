class Predicate < ActiveRecord::Base
  belongs_to :component
  belongs_to :entity

  validates_presence_of :component_id
  validates_presence_of :entity_id
  validates_presence_of :value
  validate :validate_component_type

  def values
    self.component.is_many && !self.value.blank? ? JSON.parse(self.value) : [self.value]
  end

  def add_value(index, value)
    if self.component.is_many
      vals = deserialized_values
      vals[index] = value
      self.value = vals.to_json
    else
      raise "Trying to add more than one value for a predicate which only takes one" if index != 0
      self.value = value
    end
  end

  def method_missing(method_name, *args)
    method_name[0..5] == "value_" ? values[method_name[6..-1].to_i] : super
  end

private

  def deserialized_values
    self.value.blank? ? [] : JSON.parse(self.value)
  end

  def validate_component_type
    self.values.each { |val| validate_one_value(val) }
  end

  def validate_one_value(val)
    errors.add(:value, "can't be blank") if val.blank?
    case self.component.component_type
      when ComponentType::ENTITY_REF; errors.add(:value, "must reference a valid entity.") if Entity.find_by_name(val).blank?
      when ComponentType::INTEGER; raise "TODO"
      when ComponentType::BOOLEAN; raise "TODO"
      when ComponentType::FLOAT; errors.add(:value, "must be of type float") if (Float(val) rescue false)
      when ComponentType::RANGE; raise "TODO"
      else errors.add(:value, "must be of a valid type.")
    end
  end

end

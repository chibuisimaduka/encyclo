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

  def self.validate_one_value(type, val)
    msg = "can't be blank" if val.blank?
    case type
      when ComponentType::ENTITY_REF; msg = "must reference a valid entity. Was = #{val}." if Entity.find_by_name(val).blank?
      when ComponentType::INTEGER; raise "TODO"
      when ComponentType::BOOLEAN; raise "TODO"
      when ComponentType::FLOAT; msg = "must be of type float" if (Float(val) rescue false)
      when ComponentType::RANGE; raise "TODO"
      else msg = "must be of a valid type."
    end if msg.blank?
    msg
  end

private

  def deserialized_values
    self.value.blank? ? [] : JSON.parse(self.value)
  end

  def validate_component_type
    self.values.each do |val|
      msg = Predicate.validate_one_value(self.component.component_type, val)
      errors.add(:value, msg) unless msg.blank?
    end
  end

end

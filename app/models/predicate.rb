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
      if self.component.component_type == ComponentType::ENTITY_REF
        entity = Entity.find_by_name(value)
        vals[index] = EntityRef.new(name: value, entity_id: entity ? entity.id : nil).attributes
      else
        vals[index] = value
      end
      self.value = vals.to_json
    else
      raise "Trying to add more than one value for a predicate which only takes one" if index != 0
      self.value = value
    end
  end

  def method_missing(method_name, *args)
    super unless method_name[0..5] == "value_"
    val = values[method_name[6..-1].to_i]
    self.component.component_type == ComponentType::ENTITY_REF ? EntityRef.new(val).name : val
  end

  def self.validate_one_value(type, val)
    msg = "can't be blank" if val.blank?
    case type
      when ComponentType::ENTITY_REF
        entity_ref = EntityRef.new(val)
        msg = "must reference a valid entity. Was = #{entity_ref.name}." if entity_ref.entity_id.blank?
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

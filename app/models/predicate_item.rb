class PredicateItem < ActiveRecord::Base
  belongs_to :predicate
  
  validate :validate_component_type
 
  def self.validate_component_type_msg(type, val)
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

  def validate_component_type
    msg = Predicate.validate_one_value(self.predicate.component.component_type, val)
    errors.add(:value, msg) unless msg.blank?
  end

end

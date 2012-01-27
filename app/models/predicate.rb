class Predicate < ActiveRecord::Base
  belongs_to :component
  belongs_to :entity

  validates_presence_of :component_id
  validates_presence_of :entity_id
  validates_presence_of :value
  validate :value_type

private
  def value_type
    case self.component.component_type
      when ComponentType::ENTITY; errors.add(:value, "must reference a valid entity.") if Entity.find_by_name(self.value).blank?
      when ComponentTYPE::ENTITIES
        JSON.parse(self.value).each do |val|
          errors.add(:value, "every one must reference a valid entity.") if Entity.find_by_name(val).blank?
        end
    end
    
  end
end

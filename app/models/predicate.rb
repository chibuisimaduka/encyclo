class Predicate < ActiveRecord::Base
  belongs_to :component
  belongs_to :entity

  validates_presence_of :component_id
  validates_presence_of :entity_id
  validate :value_type

private
  def value_type
    errors.add(:value, "must reference a valid entity.") if Entity.find_by_name(self.value).blank?
  end
end

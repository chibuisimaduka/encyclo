class EntityRef < ActiveRecord::Base
  belongs_to :predicate, :inverse_of => :entity_refs, :include => :component
  belongs_to :entity, :inverse_of => :references
  has_one :component, :through => :predicate

  validates_presence_of :predicate_id
  validates_presence_of :entity_id
  validates_presence_of :name
end

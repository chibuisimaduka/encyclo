class EntityRef < ActiveRecord::Base
  # ======== RELATIONS ========
  belongs_to :predicate, :inverse_of => :entity_refs, :include => :component
  belongs_to :entity, :inverse_of => :references
  has_one :component, :through => :predicate
  # ======== VALIDATIONS ========
  validates_presence_of :predicate_id
  validates_presence_of :entity_id
  validates_presence_of :name
end

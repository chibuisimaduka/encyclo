class Predicate < ActiveRecord::Base
  # ======== RELATIONS ========
  belongs_to :component, :inverse_of => :predicates
  belongs_to :entity, :inverse_of => :predicates

  has_many :entity_refs, :inverse_of => :predicate

  has_many :entities, :through => :entity_refs
  has_one :component_entity, :through => :component

  # ======== VALIDATIONS ========
  validates_presence_of :component_id
  validates_presence_of :entity_id

end

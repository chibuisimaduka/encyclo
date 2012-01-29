class Predicate < ActiveRecord::Base
  belongs_to :component, :inverse_of => :predicates
  belongs_to :entity

  validates_presence_of :component_id
  validates_presence_of :entity_id

  has_many :entity_refs, :inverse_of => :predicate
end

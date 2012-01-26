class Component < ActiveRecord::Base
  belongs_to :entity
  belongs_to :component_entity, :class_name => "Entity"

  has_many :predicates

  validates_presence_of :entity_id
  validates_presence_of :component_entity_id
end

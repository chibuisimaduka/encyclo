class Component < ActiveRecord::Base
  belongs_to :entity, :inverse_of => :associations
  belongs_to :associated_entity, :class_name => "Entity", :inverse_of => :associated_associations
  
  validates_presence_of :entity_id
  validates_presence_of :associated_entity_id
end

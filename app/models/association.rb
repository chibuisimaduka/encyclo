class Association < ActiveRecord::Base
  belongs_to :entity, :inverse_of => :associations
  belongs_to :associated_entity, :inverse_of => :associated_associations
  belongs_to :definition, :class_name => "AssociationDefinition", :foreign_key => "association_definition_id", :inverse_of => :associations
end

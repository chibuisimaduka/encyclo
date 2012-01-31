class AssociationDefinition < ActiveRecord::Base
  belongs_to :entity, :inverse_of => :association_definitions
  belongs_to :associated_entity, :inverse_of => :associated_association_definitions

  has_many :associations, :inverse_of => :definition
end

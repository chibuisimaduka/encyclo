class Association < ActiveRecord::Base
  belongs_to :entity, :inverse_of => :associations
  belongs_to :associated_entity, :class_name => "Entity", :inverse_of => :associated_associations
  belongs_to :definition, :class_name => "AssociationDefinition", :foreign_key => "association_definition_id", :inverse_of => :associations

  validates_presence_of :entity_id
  validates_presence_of :associated_entity_id
  validates_presence_of :association_definition_id

  validate :valid_association

private
  def valid_association
    if entity_id == associated_entity_id
      errors.add(:associated_entity_id, "Cannot associated with itself.")
    end
  end

end

class Association < ActiveRecord::Base
 
  default_scope includes(:delete_request)

  attr_accessible :entity_id, :associated_entity_id, :association_definition_id

  belongs_to :user, :inverse_of => :associations
  validates_presence_of :user

  belongs_to :entity, :inverse_of => :associations
  validates_presence_of :entity

  belongs_to :associated_entity, :class_name => "Entity", :inverse_of => :associated_associations
  validates_presence_of :associated_entity

  belongs_to :definition, :class_name => "AssociationDefinition", :foreign_key => "association_definition_id", :inverse_of => :associations
  validates_presence_of :definition

  has_one :delete_request, :inverse_of => :destroyable, :as => :destroyable, :dependent => :destroy

  validate :validate_not_self_referenced

private
  def validate_not_self_referenced
    if entity_id == associated_entity_id
      errors.add(:associated_entity_id, "Cannot associated with itself.")
    end
  end

end

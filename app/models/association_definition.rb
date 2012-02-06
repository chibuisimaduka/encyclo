class AssociationDefinition < ActiveRecord::Base
  belongs_to :entity, :inverse_of => :association_definitions
  belongs_to :associated_entity, :class_name => "Entity", :inverse_of => :associated_association_definitions
  belongs_to :nested_entity, :class_name => "Entity"

  has_many :associations, :inverse_of => :definition#, :dependent => :destory TODO: Able it when the site has versioning and backups.

  validates_presence_of :entity_id
  validates_presence_of :associated_entity_id
  validates_inclusion_of :entity_has_many, :in => [true, false]
  validates_inclusion_of :associated_entity_has_many, :in => [true, false]
end

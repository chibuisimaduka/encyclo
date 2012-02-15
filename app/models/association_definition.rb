class AssociationDefinition < ActiveRecord::Base
 
  default_scope includes(:delete_request)

  attr_protected :user_id, :user

  belongs_to :user, :inverse_of => :association_definitions
  validates_presence_of :user

  belongs_to :entity, :inverse_of => :association_definitions
  validates_presence_of :entity

  belongs_to :associated_entity, :class_name => "Entity", :inverse_of => :associated_association_definitions
  validates_presence_of :associated_entity

  belongs_to :nested_entity, :class_name => "Entity"

  has_many :associations, :inverse_of => :definition, :dependent => :destroy

  has_one :delete_request, :inverse_of => :destroyable, :as => :destroyable, :dependent => :destroy

  validates_inclusion_of :entity_has_many, :in => [true, false]
  validates_inclusion_of :associated_entity_has_many, :in => [true, false]
end

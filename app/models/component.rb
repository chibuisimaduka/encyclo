class Component < ActiveRecord::Base
  # ======== RELATIONS ========
  belongs_to :entity, inverse_of: :components
  belongs_to :component_entity, class_name: "Entity", inverse_of: :parent_components

  has_many :predicates, :inverse_of => :component

  # ======== VALIDATIONS ========
  validates_presence_of :entity_id
  validates_presence_of :component_entity_id
  validates_presence_of :component_type
  validates_inclusion_of :is_many, :in => [true, false]

  def name
    self.component_entity.name
  end

  def printable_name
    self.is_many ? self.component_entity.name.pluralize : self.component_entity.name
  end

end

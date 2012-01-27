class Component < ActiveRecord::Base
  belongs_to :entity
  belongs_to :component_entity, :class_name => "Entity"

  has_many :predicates

  validates_presence_of :entity_id
  validates_presence_of :component_entity_id
  validates_presence_of :component_type

  def name
    case self.component_type
      when "entity"; "#{self.component_entity.name}:"
      else "#{self.component_entity.name.pluralize}:"
    end
  end

end

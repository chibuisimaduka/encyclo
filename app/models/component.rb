class Component < ActiveRecord::Base
  belongs_to :entity
  belongs_to :component_entity, :class_name => "Entity"
end

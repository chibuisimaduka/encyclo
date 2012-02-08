class Component < ActiveRecord::Base
  belongs_to :entity, :inverse_of => :components
  belongs_to :associated_entity, :class_name => "Entity"
  has_many :entities, :inverse_of => :component

  has_one :delete_request, :inverse_of => :destroyable, :as => :destroyable
  
  validates_presence_of :entity_id
  validates_presence_of :associated_entity_id
end

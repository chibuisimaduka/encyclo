class Component < ActiveRecord::Base
 
  default_scope includes(:delete_request)

  attr_protected :user_id, :user

  belongs_to :user, :inverse_of => :components
  validates_presence_of :user

  belongs_to :entity, :inverse_of => :components
  validates_presence_of :entity

  belongs_to :associated_entity, :class_name => "Entity"
  validates_presence_of :associated_entity

  has_many :entities, :inverse_of => :component

  has_one :delete_request, :inverse_of => :destroyable, :as => :destroyable, :dependent => :destroy
  
end

class Component < ActiveRecord::Base
 
  default_scope includes(:delete_request)

  attr_protected :user_id, :user

  belongs_to :user, :inverse_of => :components
  validates_presence_of :user

  belongs_to :entity, :inverse_of => :components
  validates_presence_of :entity

  has_many :entities, :inverse_of => :component, :dependent => :destroy
  has_many :documents, :inverse_of => :component, :dependent => :destroy

  has_one :delete_request, :inverse_of => :destroyable, :as => :destroyable, :dependent => :destroy

  def associated_entity(entity_id)
    self.entities.find_by_parent_id(entity_id)
  end

  def self.components_for(entity, user)
    (entity.parents_untill_component + [entity]).flat_map do |e|
      DeleteRequest.alive_scope(e.components, user)
    end
  end

end

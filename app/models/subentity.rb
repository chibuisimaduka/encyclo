class Subentity < ActiveRecord::Base
  belongs_to :entity

  validates_presence_of :name
  validates_presence_of :entity_id

  def printable_name
    self.is_many ? self.name.pluralize : self.name
  end
end

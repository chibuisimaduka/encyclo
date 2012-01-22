class Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :entity
  #belongs_to :document

  validates_presence_of :value
  validates_presence_of :user
  validates_presence_of :entity

  def record
    self.entity_id.blank? ? self.document : self.entity
  end
end

class Source < ActiveRecord::Base
  belongs_to :entity
  validates_presence_of :entity_id
end

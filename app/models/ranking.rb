class Ranking < ActiveRecord::Base
  belongs_to :user
  belongs_to :entity
  has_many :ranking_elements, :order => "rating", :dependent => :destroy

  validates_presence_of :user_id
  validates_presence_of :entity_id

  validates_uniqueness_of :tag_id, :scope => :user_id

end

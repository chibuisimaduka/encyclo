class RankingElement < ActiveRecord::Base
  belongs_to :ranking

  validates_presence_of :ranking_id
  validates_presence_of :record_id
  validates_presence_of :rating
  
  validates_uniqueness_of :record_id, :scope => :ranking_id

  def record
    @record ||= (self.ranking.tag.type_of?("document")) ? Document.find(record_id) : Entity.find(record_id)
  end

end

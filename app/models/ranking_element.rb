class RankingElement < ActiveRecord::Base
  belongs_to :ranking

  validates_presence_of :ranking_id
  validates_presence_of :record_id
  validates_presence_of :rating
  
  validates_uniqueness_of :record_id, :scope => :ranking_id

  def record
    # FIXME: Not generic enough. Should work for entities AND documents.
    @record ||= Entity.find_by_record_id(record_id)
  end

end

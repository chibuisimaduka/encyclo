class Name < ActiveRecord::Base
  belongs_to :entity
  belongs_to :language
  
  validates_presence_of :entity
  validates_presence_of :language
  validates_presence_of :value
  
  validates_uniqueness_of :value, :case_sensitive => false, :scope => :language_id # FIXME: Also scope entity.parent_id

  def to_s
    self.value
  end

end

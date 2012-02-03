class Name < ActiveRecord::Base
  belongs_to :entity
  belongs_to :language
  
  validates_presence_of :entity
  validates_presence_of :language
  validates_presence_of :value

  validate :validate_name_uniqueness
  
  def to_s
    self.value
  end

private
  def validate_name_uniqueness
    unless Name.joins(:entity).where(["entities.parent_id = ? AND names.language_id = ?", self.entity.parent_id, self.language_id]).blank?
      errors.add(:value, "Duplicate entity name for language and entity parent.")
    end
  end

end

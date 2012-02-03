class Name < ActiveRecord::Base
  belongs_to :entity, :inverse_of => :names
  belongs_to :language, :inverse_of => :names
  
  validates_presence_of :entity
  validates_presence_of :language
  validates_presence_of :value

  validate :validate_name_uniqueness
  
  def to_s
    self.value
  end

private
  def validate_name_uniqueness
    unless Name.joins(:entity).where(["names.value = ? AND entities.parent_id = ? AND names.language_id = ?", self.value, self.entity.parent_id, self.language_id]).blank?
      errors.add(:value, "Duplicate name #{self.value} for language #{self.language.name} and entity parent #{self.entity.parent_id}.")
    end
  end

end

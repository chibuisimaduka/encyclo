class Name < ActiveRecord::Base
  belongs_to :entity, :inverse_of => :names
  belongs_to :language, :inverse_of => :names
  
  validates_presence_of :entity
  validates_presence_of :language

  has_many :possible_name_spellings, :inverse_of => :name

  validates_uniqueness_of :language_id, :scope => :entity_id
  validate :validate_name_uniqueness, :validate_universal_uniqueness, :validate_has_possible_name_spellings

  def pretty_value
    self.value.split.map(&:capitalize).join(" ")
  end

  def set_value(value, user)
    @possible_name_spelling = self.possible_name_spellings.find_or_create_by_spelling(value)
    EditRequest.update(@possible_name_spelling, @possible_name_spelling.name.possible_name_spellings, user)
    self.update_attributes(value: EditRequest.probable_editable(self.possible_name_spellings, user).spelling)
  end
  
private

  def validate_has_possible_name_spellings
    unless possible_name_spellings.length > 0
      raise "Need at least one possible name spelling."
    end
  end

  def validate_universal_uniqueness
    other_names = (self.entity.names - [self])
    if other_names.size > 0 && (self.language_id == Language::MAP[:universal].id || !(other_names.delete_if {|n| n.language_id != Language::MAP[:universal].id}).blank?)
      errors.add(:language, "You can only have one name when the language is universal.")
    end
  end
  
  def validate_name_uniqueness
    unless (Name.joins(:entity).where(["names.value = ? AND entities.parent_id = ? AND names.language_id = ?", self.value, self.entity.parent_id, self.language_id]) - [self]).blank?
      errors.add(:value, "Duplicate name #{self.value} for language #{self.language.name} and entity parent #{self.entity.parent_id}.")
    end
  end

end

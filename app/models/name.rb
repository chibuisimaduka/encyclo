class Name < ActiveRecord::Base

  attr_accessible :language, :language_id, :value

  belongs_to :entity, :inverse_of => :names
  validates_presence_of :entity

  belongs_to :language, :inverse_of => :names
  validates_presence_of :language

  has_one :edit_request, :as => :editable, :dependent => :destroy
  validates_presence_of :edit_request

  validates_presence_of :value

  validates_uniqueness_of :value, :scope => [:language_id, :entity_id]
  validate :validate_universal_uniqueness
 
  def self.language_scope(names, language)
    names.where("names.language_id = ? || names.language_id = ?", language.id, Language::MAP[:universal].id)
  end

  def pretty_value
    self.value.split.map(&:capitalize).join(" ")
  end

  alias :to_s :pretty_value

private

  def validate_universal_uniqueness
    other_names = (self.entity.names - [self])
    if other_names.size > 0 && (self.language_id == Language::MAP[:universal].id || other_names.any? {|n| n.language_id == Language::MAP[:universal].id})
      errors.add(:language, "You can only have one name when the language is universal.")
    end
  end
  
end

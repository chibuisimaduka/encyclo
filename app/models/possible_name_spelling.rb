class PossibleNameSpelling < ActiveRecord::Base
  belongs_to :name, :inverse_of => :possible_name_spellings

  has_one :edit_request, :as => :editable

  validates_presence_of :name_id
  validates_presence_of :spelling

  def pretty_value
    self.spelling.split.map(&:capitalize).join(" ")
  end

end

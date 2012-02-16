class PossibleNameSpelling < ActiveRecord::Base
  belongs_to :name, :inverse_of => :possible_name_spellings

  has_one :edit_request, :as => :editable

  #validates_presence_of :name_id #FIXME: For some reason this doesn't work for creating names. Reproduce by uncommenting and create an entity.
  validates_presence_of :spelling

  def pretty_value
    self.spelling.split.map(&:capitalize).join(" ")
  end

  def after_destroy
    name.recalculate_value
  end

end

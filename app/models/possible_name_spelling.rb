class PossibleNameSpelling < ActiveRecord::Base
  belongs_to :name, :inverse_of => :possible_name_spellings

  has_one :delete_request, :as => :destroyable

  validates_presence_of :name_id
  validates_presence_of :spelling
end

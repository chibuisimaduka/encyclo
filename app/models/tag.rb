class Tag < ActiveRecord::Base
  # TODO: Remove column name from tag

  has_and_belongs_to_many :entities

  validates_length_of :name, :in => 3..60
  #validate :name_is_unique_for_parent_tag

private
  
  def name_is_unique_for_parent_tag
    #if Tag.joins(:entity, :parent_tag).where("FIXME")
    #  error.add("The name must be unique for the same parent tag.")
    #end
  end

end

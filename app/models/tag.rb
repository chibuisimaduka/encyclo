class Tag < ActiveRecord::Base
  has_many :tags, :order => "name"
  belongs_to :tag

  has_many :sources

  belongs_to :image

  has_many :entities, :order => "rank DESC"
  has_and_belongs_to_many :related_entities, :class_name => "Entity" # FIXME: Remove order rank if it is slower because not used when RankingType == USER
  has_many :rankings, :include => :ranking_elements

  validates_length_of :name, :in => 3..24
  validates_uniqueness_of :name, :scope => :tag_id

  #has_many :similarity_groups
  
  def full_name
    self.tag ? self.name + " " + self.tag.full_name : self.name
  end

  def all_entities
    self.tags.blank? ? self.entities : self.tags.map(&:all_entities).flatten + self.entities
  end

  # Wheter the tag or any of it's ancestors as the name given.
  def type_of?(tag_name)
    self.name == tag_name || (self.tag != nil && self.tag.type_of?(tag_name))
  end

  def ranking_for(user)
    self.rankings.find_by_user_id(user.id) if user
  end

end

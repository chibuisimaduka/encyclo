class Tag < ActiveRecord::Base
  # TODO: Remove column name from tag
  has_one :tag, :through => :entity, :source => :parent_tag
  has_many :tags, :through => :entities, :source => :tag

  has_many :sources

  belongs_to :image

  belongs_to :entity
  validates_presence_of :entity_id

  has_many :entities, :order => "rank DESC", :include => :documents
  has_and_belongs_to_many :related_entities, :class_name => "Entity" # FIXME: Remove order rank if it is slower because not used when RankingType == USER
  has_many :rankings, :include => :ranking_elements

  validates_length_of :name, :in => 3..60
  #validate :name_is_unique_for_parent_tag

  #has_many :similarity_groups
  
  def full_name
    self.tag ? self.name + " " + self.tag.full_name : self.name
  end

  def all_entities
    self.tags.blank? ? self.entities : self.tags.map(&:all_entities).flatten + self.entities
  end

  def all_tags
    self.tag.blank? ? [self] : self.tag.all_tags + [self]
  end

  # Wheter the tag or any of it's ancestors as the name given.
  def type_of?(tag_name)
    self.name == tag_name || (self.tag != nil && self.tag.type_of?(tag_name))
  end

  def ranking_for(user)
    self.rankings.find_by_user_id(user.id) if user
  end

private
  
  def name_is_unique_for_parent_tag
    if Tag.joins(:entity, :parent_tag).where("FIXME")
      error.add("The name must be unique for the same parent tag.")
    end
  end

end

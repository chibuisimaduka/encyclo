class Tag < ActiveRecord::Base
  has_many :tags
  belongs_to :tag

  belongs_to :image

  has_many :entities, :order => "rank DESC"
  has_and_belongs_to_many :related_entities, :class_name => "Entity" # FIXME: Remove order rank if it is slower because not used when RankingType == USER
  has_many :rankings, :include => :ranking_elements

  validates_length_of :name, :in => 3..24
  validates_uniqueness_of :name, :through => :tag_id

  #has_many :similarity_groups
  
  def similar_tags
    similar_tags_count = {}
    tags = {}
	 self.entities.each do |e|
	   e.tags.each do |t|
        tags[t.id] = t
        similar_tags_count[t.id] = (similar_tags_count[t.id] or 0) + 1
		end
	 end
	 similar_tags_count.delete self.id
    (similar_tags_count.sort_by{|k,v| v}).reverse[0..9].collect(&:first).collect {|i| tags[i]}
  end

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

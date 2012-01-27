class Entity < ActiveRecord::Base
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :documents, :order => "rank DESC"
  has_many :entity_similarities
  
  belongs_to :parent, :class_name => "Entity"
  has_many :entities, :order => "rank DESC", :include => :documents, :foreign_key => :parent_id
  
  has_many :ratings
  
  has_many :sources

  has_many :images

  has_many :subentities

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :parent_id

  has_many :components
  has_many :parent_components, :class_name => "Component", :foreign_key => "component_entity_id"

  has_many :predicates

  #before_save :update_documents_from_tag_sources
  
  #def tag_name
  #  self.parent_tag.name
  #end

  #def tag_name=(name)
  #  self.parent_tag = Tag.find_or_create_by_name(name) unless name.blank?
  #end

  def suggested_rating(ranking_elements)
    expected_rating = 0.0
    similarity_sum = 0.0
    entity_similarities.each do |s|
      other_elem = ranking_elements[s.other_entity_id]
      next unless other_elem
      expected_rating += other_elem.rating * s.coefficient
      similarity_sum += s.coefficient
    end
    similarity_sum == 0.0 ? 0.0 : expected_rating / similarity_sum
  end

  def new_tag_name
    @new_tag_name
  end

  def new_tag_name=(name)
    self.tags << Tag.find_or_create_by_name(name)
    @new_tag_name = name
  end

  def all_components
    self.parent.blank? ? self.components : self.components + self.parent.all_components
  end

  def all_entities
    self.entities + self.entities.map(&:all_entities).flatten
  end

  def rating_for(user)
    self.ratings.find_by_user_id(user.id)
  end

  def all_subentities
    self.parent.blank? ? self.subentities : self.subentities + self.parent.all_subentities
  end

  def update_documents_from_sources
    one_created = false
    (self.ancestors + [self]).each do |e|
      e.sources.each do |source|
        one_created |= Document.create(self, source)
      end
    end
    one_created ? true : nil # Returning false cancels the save.
  end

  def ancestors
    self.parent.blank? ? [] : [self.parent] + self.parent.ancestors
  end

  def unambiguous_name
    self.name + " (" + self.parent.name + ")"
  end

end

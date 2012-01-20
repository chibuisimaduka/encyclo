class Entity < ActiveRecord::Base
  belongs_to :parent_tag, :class_name => "Tag", :foreign_key => "tag_id"
  has_one :tag, :dependent => :destroy
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :documents, :order => "rank DESC"
  has_many :entity_similarities

  has_many :images

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :tag_id
  
  #before_save :update_documents_from_tag_sources
  
  def tag_name
    self.parent_tag.name
  end

  def tag_name=(name)
    self.parent_tag = Tag.find_or_create_by_name(name) unless name.blank?
  end

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

  def update_documents_from_tag_sources
    one_created = false
    self.parent_tag.all_tags.each do |t|
      t.sources.each do |source|
        one_created |= Document.create(self, source)
      end
    end
    one_created ? true : nil # Returning false cancels the save.
  end

  def ancestors
    self.parent_tag ? [self.parent_tag] + self.parent_tag.entity.ancestors : []
  end

  def unambiguous_name
    self.name + " ( " + self.parent_tag.name + " )"
  end

end

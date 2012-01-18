class Entity < ActiveRecord::Base
  belongs_to :tag
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :documents, :order => "rank DESC"
  has_many :entity_similarities

  has_many :images

  validates_presence_of :name
  
  before_save :update_documents_from_tag_sources
  
  def tag_name
    self.tag.name
  end

  def tag_name=(name)
    self.tag = Tag.find_or_create_by_name(name) unless name.blank?
  end

  def also_tag?
    !Tag.find_by_name(self.name).blank?
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
    one_created = false; self.tag.sources.each { |source| one_created |= Document.create(self, source) }; one_created
  end

end

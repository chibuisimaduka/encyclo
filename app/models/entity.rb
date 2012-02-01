class Entity < ActiveRecord::Base
  # ======== RELATIONS ========
  #has_and_belongs_to_many :tags
  has_and_belongs_to_many :documents, :order => "rank DESC"
  
  belongs_to :parent, :class_name => "Entity", :inverse_of => :entities
  has_many :entities, :order => "rank DESC", :include => :documents, :foreign_key => :parent_id, :inverse_of => :parent
  
  has_many :entity_similarities
  has_many :ratings
  has_many :sources
  has_many :images

  has_many :subentities

  has_many :association_definitions, :inverse_of => :entity
  has_many :associated_association_definitions, :class_name => "AssociationDefinition", :foreign_key => "associated_entity_id", :inverse_of => :associated_entity

  has_many :associations, :inverse_of => :entity
  has_many :associated_associations, :class_name => "Association", :foreign_key => "associated_entity_id", :inverse_of => :associated_entity

  # ======== TODO: DEPRECATED ========

  #has_many :predicates, :inverse_of => :entity

  #has_many :components, :inverse_of => :entity
  #has_many :parent_components, :class_name => "Component", :foreign_key => "component_entity_id", :inverse_of => :component_entity

  #has_many :references, :class_name => "EntityRef", :inverse_of => :entity, :include => [:predicate => :component]

  # ======== VALIDATIONS ========
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :parent_id

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

  def rating_for(user)
    self.ratings.find_by_user_id(user.id)
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

  def parents_by_definition
    (self.associations.all(:include => [:definition => :entity]).map(&:definition).map(&:entity) +
    self.associated_associations.all(:include => [:definition => :associated_entity]).map(&:definition).map(&:associated_entity)).uniq
  end

  def entities_by_definition
    # Maybe include childs childs..
    (self.association_definitions.all(:include => [:associations => :entity]).map(&:associations).flatten.map(&:entity) +
    self.associated_association_definitions.all(:include => [:associations => :associated_entity]).map(&:associations).flatten.map(&:associated_entity)).uniq
  end

  def all_association_definitions
    self.map_all :parent do |a|
      (a.association_definitions || []) + (a.associated_association_definitions || [])
    end
  end
end

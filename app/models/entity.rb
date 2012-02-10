class Entity < ActiveRecord::Base
 
  default_scope includes([:ratings, :delete_request])

  # ======== RELATIONS ========
  has_and_belongs_to_many :documents, :order => "rank DESC"
  
  belongs_to :parent, :class_name => "Entity", :inverse_of => :entities
  has_many :entities, :order => "rank DESC", :include => :documents, :foreign_key => :parent_id, :inverse_of => :parent
  
  has_many :entity_similarities
  has_many :ratings, :inverse_of => :rankable, :as => :rankable, :dependent => :destroy
  has_many :sources
  has_many :images, :order => "rank DESC"

  has_many :association_definitions, :inverse_of => :entity, :dependent => :destroy
  has_many :associated_association_definitions, :class_name => "AssociationDefinition", :foreign_key => "associated_entity_id", :inverse_of => :associated_entity, :dependent => :destroy

  has_many :associations, :inverse_of => :entity, :dependent => :destroy
  has_many :associated_associations, :class_name => "Association", :foreign_key => "associated_entity_id", :inverse_of => :associated_entity, :dependent => :destroy

  has_many :associations_definitions, :through => :associations, :source => "definition"
  has_many :associated_associations_definitions, :through => :associated_associations, :source => "definition"

  has_many :parents_by_definition, :through => :associations_definitions, :source => :entity
  has_many :associated_parents_by_definition, :through => :associated_associations_definitions, :source => :associated_entity

  has_many :names, :inverse_of => :entity, :dependent => :destroy

  has_many :components, :inverse_of => :entity, :dependent => :destroy
  belongs_to :component, :inverse_of => :entities, :dependent => :destroy

  has_one :delete_request, :inverse_of => :destroyable, :dependent => :destroy, :as => :destroyable

  belongs_to :user, :inverse_of => :entities
  validates_presence_of :user_id

  validate :validate_has_one_name, :validate_not_parent_of_itself

  self.per_page = 20

  def component_entities
    self.entities.where("component_id IS NOT NULL")
  end

  def subentities
    self.entities.where("component_id IS NULL")
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

  def update_documents_from_sources
    one_created = false
    (self.ancestors + [self]).each do |e|
      e.sources.each do |source|
        one_created |= Document.create(self, source)
      end
    end
    one_created ? true : nil # Returning false cancels the save.
  end

  def entities_by_definition
    (self.association_definitions.all(:include => [:associations => :entity]).map(&:associations).flatten.map(&:entity) +
    self.associated_association_definitions.all(:include => [:associations => :associated_entity]).map(&:associations).flatten.map(&:associated_entity)).uniq
  end

  def all_association_definitions
    self.map_all :parent do |a|
      (a.association_definitions || []) + (a.associated_association_definitions || [])
    end
  end

  def is_component?
    !self.component_id.blank?
  end

  def name(user, language)
    user_name = EditRequest.user_editable(raw_name(language).possible_name_spellings, user) 
    user_name ? user_name.pretty_value : raw_name(language).pretty_value
  end

  def raw_name(language)
    raw_name = names.find_by_language_id(language.id)
    raw_name ||= names.find_by_language_id(Language::MAP[:english].id) unless language.id == Language::MAP[:english].id
    raw_name ||= names.first
  end

private

  def validate_has_one_name
    errors.add(:names, "An entity needs at leat one name.") unless self.names.length > 0
  end

  def validate_not_parent_of_itself
    errors.add(:parent_id, "An entity can't be parent of itself") if self.id == parent_id
  end

end

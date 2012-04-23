class Entity < ActiveRecord::Base

  #default_scope includes([:parent, :ratings, :delete_request, :documents, :images, :names => {:edit_request => :agreeing_users}])

  attr_protected :user_id, :user, :ancestors, :ancestor_ids, :little_descendants, :little_desendant_ids

  # ======== RELATIONS ========
  has_and_belongs_to_many :documents, :order => "rank DESC"
  
  belongs_to :parent, :class_name => "Entity", :inverse_of => :entities
  has_many :entities, :order => "rank DESC", :include => :documents, :foreign_key => :parent_id, :inverse_of => :parent
  
  has_many :entity_similarities
  has_many :ratings, :inverse_of => :rankable, :as => :rankable, :dependent => :destroy
  has_many :sources
  has_many :images, :inverse_of => :entity, :order => "rank DESC", :dependent => :destroy

  has_many :association_definitions, :inverse_of => :entity, :dependent => :destroy
  has_many :associated_association_definitions, :class_name => "AssociationDefinition", :foreign_key => "associated_entity_id", :inverse_of => :associated_entity, :dependent => :destroy

  has_many :associations, :inverse_of => :entity, :dependent => :destroy
  has_many :associated_associations, :class_name => "Association", :foreign_key => "associated_entity_id", :inverse_of => :associated_entity, :dependent => :destroy

  has_many :association_definitions_associations, :through => :association_definitions, :source => :associations
  has_many :associated_association_definitions_associations, :through => :associated_association_definitions, :source => :associations

  has_many :direct_entities_by_definition, :through => :association_definitions_associations, :source => :entity
  has_many :indirect_entities_by_definition, :through => :associated_association_definitions_associations, :source => :associated_entity

  # A little descendant does not include close descendants. @see descendants
  has_and_belongs_to_many :little_descendants, :class_name => "Entity", :join_table => "entities_ancestors", :foreign_key => :ancestor_id
  has_and_belongs_to_many :ancestors, :class_name => "Entity", :join_table => "entities_ancestors", :association_foreign_key => :ancestor_id

  has_many :names, :inverse_of => :entity, :dependent => :destroy

  has_many :components, :inverse_of => :entity, :dependent => :destroy
  belongs_to :component, :inverse_of => :entities

  has_one :delete_request, :inverse_of => :destroyable, :dependent => :destroy, :as => :destroyable

  belongs_to :user, :inverse_of => :entities
  validates_presence_of :user

  has_one :home_user, :class_name => "User", :inverse_of => :home_entity

  validate :validate_has_one_name, :validate_not_parent_of_itself

  before_save :calculate_ancestors

  before_destroy :destroy_documents

  validates_inclusion_of :is_intermediate, :in => [true, false]

  accepts_nested_attributes_for :associations

  self.per_page = 20

  ROOT_ENTITY = Entity.find(724)

  def self.create(attributes, user, language, raw_name)
    entity = Entity.new(attributes)
    entity.user = user
    entity.set_name(raw_name, user, language) unless raw_name.blank?
    entity
  end

  def descendants
    self.little_descendants | self.entities | self.entities_by_definition
  end
 
  def self.component_scope(entities)
    entities.where("entities.component_id IS NOT NULL")
  end

  def self.subentity_scope(entities)
    entities.where("entities.component_id IS NULL")
  end

  def all_associations(user, reload=false)
    @all_assocs = @all_assocs && !reload ? @all_assocs : DeleteRequest.alive_scope(associations, user) +
      ReversedAssociation.reverse(DeleteRequest.alive_scope(associated_associations, user))
  end

  def all_association_definitions(user, reload=false)
    @all_assoc_defs = @all_assoc_defs && !reload ? @all_assoc_defs : DeleteRequest.alive_scope(association_definitions, user) +
      ReversedAssociationDefinition.reverse(DeleteRequest.alive_scope(associated_association_definitions))
  end

  def death_treshold
    # If death_treshold was an attribute, the following could be done.
    #Math.log(self.entities.sum(&:death_treshold) + self.associations.count + self.documents.sum(&:death_treshold) + self.ratings.count + self.association_definitions.sum(&:death_treshold) + self.names.count)
    Math.log(self.entities.count + self.associations.count + self.documents.count + self.ratings.count + self.association_definitions.count + self.names.count)
  end

  def subentities_leaves(checked_entities=nil)
    return [] if checked_entities && checked_entities.include?(self.id)
    (self.subentities.limit(10).map do |e|
      es = e.subentities.limit(10)
      es.blank? ? e : e.subentities_leaves((checked_entities || []) + [self.id])
    end).flatten
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
    self.direct_entities_by_definition | self.indirect_entities_by_definition
  end

  def is_component?
    !self.component_id.blank?
  end

  def name(user, language)
    name = EditRequest.user_editable(Name.language_scope(names, language), user)
    name ||= Name.language_scope(names, language).first
    name ||= names.find_by_language_id(Language::MAP[:english].id) unless language.id == Language::MAP[:english].id
    name ||= names.first
  end

  def set_name(value, user, language)
    # Active record does not do that association like expected.
    #name = names.find_or_initialize_by_value(value)
    name = names.where("value = ? collate utf8_bin", value).first || names.build(value: value)
    EditRequest.update(name, names, user)
    name.language = language
    name
  end

  def listing_documents
    documents.where('documents.documentable_type = "ListingDocument"')
  end

  def calculate_ancestors
    old_ancestors = self.ancestors
    self.ancestors = self.parent.ancestors + [self.parent] if self.parent
    set_child_ancestors((self.ancestors || []) + [self]) unless self.ancestors == old_ancestors
  end

  def set_child_ancestors(child_ancestors)
    Entity.subentity_scope(self.entities.includes(:entities, :ancestors)).each do |e|
      e.update_attribute :ancestors, child_ancestors unless e.ancestors == child_ancestors
      e.set_child_ancestors(child_ancestors + [e]) # OPTIMIZE: Can I skip this if e.ancestors == ancestors.
    end
  end

  def self.find_all_by_id_or_by_name(id, name, language)
    # FIXME: Doesn't work if current_user has change the name.
    id.blank? ? Name.find_all_by_language_id_and_value(language.id, name).map(&:entity) : [Entity.find(id)]
  end
  
  # Stops when parent_id is nil or the entity is a component
  def parents_untill_component
    !self.parent_id.blank? && self.component_id.blank? ? self.parent.parents_untill_component + [self.parent] : []
  end

  def predicates
    all_association_definitions(nil).map(&:associated_entity)
  end

  def associations_values
    associations_values = {}
    (self.ancestors + [self]).flat_map(&:associations).each do |association|
      unless DeleteRequest.alive?(association)
        associations_values[association.association_definition_id] = (associations_values[association.association_definition_id] || []) + [association.associated_entity_id] 
      end
    end
    (self.ancestors + [self]).flat_map(&:associated_associations).each do |association|
      unless DeleteRequest.alive?(association)
        associations_values[association.association_definition_id] = (associations_values[association.association_definition_id] || []) + [association.entity_id] 
      end
    end
    associations_values
  end

  def self.filter_scope(entities, filters, language)
    return entities if filters.blank?

    filters.each_with_index do |(definition_id, v), i|
      unless v["name"].blank?
        if v["id"].blank?
          names = Name.language_scope(Name).find_all_by_value(v["name"]) #TODO: Scope by definition too.
          raise "Ambiguous name." if names.size != 1
          value_id = names.first.entity.id
        else
          value_id = v["id"]
        end
        entities = entities.joins("INNER JOIN associations AS filter_associations_#{i} ON filter_associations_#{i}.entity_id = entities.id OR filter_associations_#{i}.associated_entity_id = entities.id").where("filter_associations_#{i}.association_definition_id = #{definition_id} and (filter_associations_#{i}.associated_entity_id = #{value_id} or filter_associations_#{i}.entity_id = #{value_id})")
      end
    end
    
    entities
  end

  def parent_is_intermediate
    parent && parent.is_intermediate
  end

  def rank=(updated_rank)
    @old_rank = rank
    super
  end

  after_save :update_entity_suggestions
  def update_entity_suggestions
    if @old_rank
      # FIXME: Creating an entity uselessly.
      EntitySuggestionsService.instance.update_entity(Entity.new(id: id, rank: @old_rank), self)
    end
  end

  def <=>(entry)
    cmp = self.rank <=> entry.rank
    cmp == 0 ? self.entity.id <=> entry.entity.id : eq
  end

private

  def validate_has_one_name
    errors.add(:names, "An entity needs at leat one name.") unless names.length > 0 || (parent && parent.is_intermediate)
  end

  def validate_not_parent_of_itself
    errors.add(:parent_id, "An entity can't be parent of itself") if self.id == parent_id
  end

  def destroy_documents
    documents.destroy_all
  end

end

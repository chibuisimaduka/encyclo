module EntitiesHelper
  
  def associations_by_definition(entity)
    associations_by_def = {}
    entity.map_all(:parent, false, &:association_definitions).each do |association_definition|
      associations_by_def[association_definition] = []
    end
    entity.map_all(:parent, &:associations).each do |association|
      associations_by_def[association.definition] = (associations_by_def[association.definition] || []) + [association] unless destroyable_deleted?(association)
    end
    associations_by_def.sort {|k,v| v.size }
  end

  def associated_associations_by_definition(entity)
    associations_by_def = {}
    entity.map_all(:parent, false, &:associated_association_definitions).each do |association_definition|
      associations_by_def[association_definition] = []
    end
    entity.map_all(:parent, &:associated_associations).each do |association|
      associations_by_def[association.definition] = (associations_by_def[association.definition] || []) + [association] unless destroyable_deleted?(association)
    end
    associations_by_def.sort {|k,v| v.size }
  end

  def nested_entity_values(entity, nested_entity, associated_entity)
    entities = nested_entities_for(entity, nested_entity)
    (entities.map {|e| nested_entities_for(e, associated_entity) }).flatten
  end

  def nested_entities_for(entity, nested_entity)
    if ((nested_def = definition_for(entity, nested_entity)) && (nested_nested_entity = nested_def.nested_entity))
       (nested_entities_for(entity, nested_nested_entity).map {|e| nested_entities_for(e, nested_entity) }).flatten
    else
      associations = entity.associations.joins(:definition).where("association_definitions.associated_entity_id = ?", nested_entity.id)
      (!associations.blank?) ? associations.map(&:associated_entity) :
        entity.associated_associations.joins(:definition).where("association_definitions.entity_id = ?", nested_entity.id).map(&:entity)
    end
  end

  def definition_for(entity, nested_entity)
    association_definition = entity.map_all(:parent, &:association_definitions).select {|a| a.associated_entity_id == nested_entity.id }
    (association_definition.blank? ? (entity.map_all(:parent, &:associated_association_definitions).select {|a| a.entity_id == nested_entity.id }) : association_definition).first
  end

  def join(array, separator=" ", &block)
    str = ""
    array.each do |e|
      str += capture(e, &block).to_s
      str += separator
    end
    str = str[0..-(separator.size + 1)] unless array.blank?
    str.html_safe
  end

  def link_to_entity(entity)
    link_to entity_name(entity), entity
    #link_to entity_name(entity), entity, remote: true, format: :js
  end

  def best_in_place_entity_name(entity, is_link=false)
    name = raw_entity_name(entity)
    out = best_in_place(is_link ? BestInPlaceEntityLink.new(entity, name, self) : name, :value, {display_as: :pretty_value, activator: "#rename_#{name.id}", path: {:controller => :names, :action => :update, :entity_id => entity.id, :id => name.id}, object_name: :name})
    #out = is_link ? link_to(best_in_place_name, entity, remote: true, format: :js) : best_in_place_name
    out << exception_star("This is the english name. Click to enter the french name.") unless name.language_id == current_language.id
    out << (content_tag :span, :id => "rename_#{name.id}" do
      "&nbsp".html_safe + image_tag("edit_button.png")
    end)
    raw out
  end

  def exception_star(msg)
    "<span class='exception_star' title='#{msg}'>*</span>".html_safe
  end
private

  class BestInPlaceEntityLink
    def initialize(entity, name, helper)
      @entity = entity
      @name = name
      @helper = helper
    end

    def value
      @name.value
    end

    def pretty_value
      @helper.link_to(@name.pretty_value, @entity)
    end
  end

end

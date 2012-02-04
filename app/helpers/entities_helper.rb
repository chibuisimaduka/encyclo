module EntitiesHelper
  
  def associations_by_definition(entity)
    associations_by_def = {}
    entity.map_all(:parent, false, &:association_definitions).each do |association_definition|
      associations_by_def[association_definition] = []
    end
    entity.associations.each do |association|
      associations_by_def[association.definition] = (associations_by_def[association.definition] || []) + [association]
    end
    associations_by_def
  end

  def associated_associations_by_definition(entity)
    associations_by_def = {}
    entity.map_all(:parent, false, &:associated_association_definitions).each do |association_definition|
      associations_by_def[association_definition] = []
    end
    entity.associated_associations.each do |association|
      associations_by_def[association.definition] = (associations_by_def[association.definition] || []) + [association]
    end
    associations_by_def
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
  end

  def best_in_place_entity_name(entity, is_link=false)
    name = raw_entity_name(entity)
    best_in_place_name = best_in_place(name, :value, {display_as: :pretty_value, activator: "#rename_#{name.id}", path: {:controller => :names, :action => :update, :entity_id => entity.id, :id => name.id}})
    out = is_link ? link_to(best_in_place_name, entity) : best_in_place_name
    out << exception_star("This is the english name. Click to enter the french name.") unless name.language_id == current_language.id
    out << "<span id='rename_#{name.id}'>[e]</span>".html_safe
    raw out
  end

  def entity_name(entity)
    raw_entity_name(entity).pretty_value
  end

  def exception_star(msg)
    "<span class='exception_star' title='#{msg}'>*</span>".html_safe
  end
private

  def raw_entity_name(entity)
    entity.names.find_by_language_id(current_language.id) || entity.names.first
  end

end

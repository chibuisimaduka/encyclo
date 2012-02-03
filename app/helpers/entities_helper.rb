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

  def entity_name(entity)
    name = entity.names.find_by_language_id(current_language.id) || entity.names.first
    name.value.split.map(&:capitalize).join(" ") if name
  end

end

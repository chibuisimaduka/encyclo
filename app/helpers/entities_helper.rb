module EntitiesHelper
  
  def associations_by_definition(entity)
    associations_by_def = {}
    entity.ancestors.flat_map(&:association_definitions).each do |association_definition|
      associations_by_def[association_definition] = []
    end
    # Using the parent also because if the Asterix and Obelix serie is written by Uderzo and Gosciny, so is every of it's child.
    (entity.ancestors + [entity]).flat_map(&:associations).each do |association|
      associations_by_def[association.definition] = (associations_by_def[association.definition] || []) + [association] unless DeleteRequest.alive?(association, current_user)
    end
    associations_by_def.sort {|k,v| v.size }
  end

  def associated_associations_by_definition(entity)
    associations_by_def = {}
    entity.ancestors.flat_map(&:associated_association_definitions).each do |association_definition|
      associations_by_def[association_definition] = []
    end
    # Using the parent also because if the Asterix and Obelix serie is written by Uderzo and Gosciny, so is every of it's child.
    (entity.ancestors + [entity]).flat_map(&:associated_associations).each do |association|
      associations_by_def[association.definition] = (associations_by_def[association.definition] || []) + [association] unless DeleteRequest.alive?(association, current_user)
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

  def link_to_entity(entity)
    link_to entity.name(current_user, current_language), entity
    #link_to entity_name(entity), entity, remote: true, format: :js
  end

end

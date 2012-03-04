module ComponentsHelper

  def create_component_value_link(entity, component, name)
    path = 
    link_to name, entities_path(entity: {:parent_id => entity.id, :component_id => component.id}, name: name.value, show: true), method: :post
  end

  def associated_value_name(component, associated_value, user, language)
    associated_value.name(user, language)
  end

end

class PathsController < ApplicationController

  def index
    entity = process_path_or_render_error(params[:path], default: ".")
    entities = params[:partial_name] ? entity.entities.joins(:names)
      .where("names.value like ?", "#{params[:partial_name]}%") : entity.entities
    render :json => {names: entities.map {|e| e.name(current_user, current_language) }} if entity
  end

  def get_entity
    entity = process_path_or_render_error(params[:path], default: "~")
    render :json => {entity: entity} if entity
  end

private

  def process_path_or_render_error(path, options={})
    entity_or_error_msg = process_path(params[:path], options)
    if entity_or_error_msg.is_a?(String)
      render :json => {error: entity_or_error_msg}
      nil
    else
      entity_or_error_msg
    end
  end

  # Returns the entity for the path, or a string with an error.
  def process_path(path, options={})
    if path.blank?
      return "Path can't be blank!" unless options[:default]
      path = options[:default]
    end

    entity_names = path.split('/')
    entities = []
    if entity_names.first.blank?
      entities << Entity::ROOT_ENTITY
    elsif entity_names.first == '~'
      return "You must be logged in to have a home." if current_user.is_ip_address
      entities << current_user.home_entity
    elsif entity_names.first == '..'
      return "There is no current entity." if params[:current_entity].blank?
      entities << Entity.find(params[:current_entity]).parent
    elsif entity_names.first == '.'
      return "There is no current entity." if params[:current_entity].blank?
      entities << Entity.find(params[:current_entity])
    end
    
    (entities.blank? ? entity_names : (entity_names[1..-1] || [])).each do |name|
      entity = if name == ".."
        entities.last.parent
      else
        (entities.last || Entity.find(params[:current_entity])).entities.joins(:names).where("(names.language_id = ? or names.language_id = ?) and names.value = ?", Language::MAP[:universal], current_language.id, name).first
      end
      return "Entity with name = #{name} does not exists." if entity.blank?
      entities << entity
    end
    entities.last
  end

end

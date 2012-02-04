class NamesController < ApplicationController

  respond_to :html, :json

  def update
    @name = Name.find(params[:id])
    if @name.language == current_language
      @name.update_attributes(params[:name])
    else
      @name = Name.new(language_id: current_language.id, entity_id: params[:entity_id], value: params[:name][:value])
      @name.save
    end
    respond_with @name
  end

end

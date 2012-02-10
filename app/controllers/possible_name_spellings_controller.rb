class PossibleNameSpellingsController < ApplicationController

  def create
    @name = Name.find(params[:name_id])
    if @name.language != current_language
      @name = Name.new(language_id: current_language.id, entity_id: params[:entity_id], value: params[:name][:value])
    end
    @name.set_value(params[:possible_name_spelling][:spelling], current_user)
  end

end

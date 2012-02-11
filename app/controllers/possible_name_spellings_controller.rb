class PossibleNameSpellingsController < ApplicationController

  def create
    @name = (@original_name = Name.find(params[:name_id]))
    if @name.language != current_language
      @name = Name.new(language_id: current_language.id, entity_id: @name.entity_id)
    end
    @name.set_value(params[:possible_name_spelling][:spelling], current_user)
  end

end

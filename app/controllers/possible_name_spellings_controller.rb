class PossibleNameSpellingsController < ApplicationController

  def create
    @name = Name.find(params[:name_id])
    @name.set_value(params[:possible_name_spelling][:spelling], current_user)
  end

end

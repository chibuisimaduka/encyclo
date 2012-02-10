class PossibleNameSpellingsController < ApplicationController

  def create
    @name = Name.find(params[:name_id])
    @possible_name_spelling = @name.possible_name_spellings.find_or_create_by_spelling(params[:possible_name_spelling][:spelling])
    EditRequest.update(@possible_name_spelling, current_user)
    @name.update_attributes(value: EditRequest.probable_editable(@name.possible_name_spellings, current_user))
    redirect_to :back
  end

end

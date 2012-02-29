class NamesController < ApplicationController

  def update
    @original_name = Name.find(params[:id])
    @name = @original_name.entity.set_name(params[:name][:value], current_user, current_language)
    @name.save! # FIXME
  end

end

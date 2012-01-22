class RatingsController < ApplicationController
 
  respond_to :html, :json

  def update
    @rating = Rating.find_or_initialize_by_entity_id_and_user_id(params[:id], current_user.id)
    @record = @rating.record
    value = params[:rating][:value].to_f
    updated_rank = ((@record.rank || 0) * @record.num_votes) - (@rating.value || 0) + value
    if value == 0.0 && @rating.persisted?
      @record.num_votes -= 1
      @record.rank = @record.num_votes == 0 ? nil : updated_rank / @record.num_votes
      @rating.destroy
      respond_with Rating.new(entity_id: @record.id, user_id: current_user.id)
    else
      @record.num_votes += 1 unless @rating.persisted?
      @record.rank = updated_rank / @record.num_votes
      @record.save!
      @rating.persisted? ? @rating.update_attribute(:value, value) : @rating.value = value; @rating.save!
      respond_with @rating
    end
  end

  def rank_up
    raise "TODO"
  end

  def rank_down
    raise "TODO"
  end

  def sort
    raise "TODO"
  end

end

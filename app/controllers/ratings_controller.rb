class RatingsController < ApplicationController
 
  respond_to :html, :json

  def update
    @rating = Ranting.find_or_initialize_by_entity_id_and_user_id(params[:id], current_user.id)
    @record = @rating.record
    value = params[:rating][:value].to_f
    updated_rank = ((@record.rank || 0) * @record.num_votes) - (@rating.value || 0) + value
    if value == 0.0 && @rating.persisted?
      @record.num_votes -= 1
      @record.rank = @record.num_votes == 0 ? nil : updated_rank / @record.num_votes
      @rating.destroy
    else
      @record.num_votes += 1 unless @rating.persisted?
      @record.rank = updated_rank / @record.num_votes
      @record.save!
      @rating.persisted? ? @rating.update_attribute(:value, value) : @rating.save!
    end
    respond_with @rating # Respond_with when destroying?
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

class RatingsController < ApplicationController
 
  respond_to :html, :json

  def update
    @rating = Rating.find_or_initialize_by_entity_id_and_user_id(params[:id], current_user.id)
    @record = @rating.record
    value = params[:rating][:value].to_f
    updated_rank = ((@record.rank || 0) * @record.ratings.size) - (@rating.value || 0) + value
    if value == 0.0 && @rating.persisted?
      @record.ratings.delete(@rating)
      @record.update_attribute :rank, (@record.ratings.size == 0) ? nil : updated_rank / @record.ratings.size
      respond_with Rating.new(entity_id: @record.id, user_id: current_user.id)
    else
      @record.update_attribute :rank, updated_rank / (@rating.persisted? ? @record.ratings.size : @record.ratings.size + 1)
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

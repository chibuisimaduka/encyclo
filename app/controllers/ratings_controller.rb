class RatingsController < ApplicationController
 
  respond_to :html, :json

  def update
    @rankable = find_polymorphic_association
    @rating = @rankable.ratings.find_or_initialize_by_user_id(current_user.id)
    value = params[:rating][:value].to_f
    updated_rank = ((@rankable.rank || 0) * @rankable.ratings.size) - (@rating.value || 0) + value
    if params[:rating][:value] == "null" && @rating.persisted?
      @rankable.ratings.delete(@rating)
      @rankable.update_attribute :rank, (@rankable.ratings.size == 0) ? nil : updated_rank / @rankable.ratings.size
      respond_with Rating.new(rankable_id: @rankable.id, user_id: current_user.id)
    elsif params[:rating][:value] != "null"
      if @rating.persisted? ? @rating.update_attributes(value: value) : @rating.value = value; @rating.save
        @rankable.update_attributes(rank: updated_rank / @rankable.ratings.size)
      end
      respond_with @rating
    end
  end

end

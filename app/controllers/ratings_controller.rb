class RatingsController < ApplicationController
 
  def update
    @rankable = find_polymorphic_association
    @rating = @rankable.ratings.find_or_initialize_by_user_id(current_user.id)
    value = params[:rating][:value].to_f
    if @rating.persisted? ? @rating.update_attributes(value: value) : @rating.value = value; @rating.save
      updated_rank = ((@rankable.rank || 0) * @rankable.ratings.size) - (@rating.value || 0) + value
      @rankable.update_attributes(rank: updated_rank / @rankable.ratings.size)
    end
  end

  def destroy
    @rating = Rating.find(params[:id])
    if @rating.user_id == current_user.id
      @rating.destroy
      redirect_to :back
    else
      redirect_to :back, :alert => "This is not your rating that you are trying to delete! We're watching you.."
    end
  end

end

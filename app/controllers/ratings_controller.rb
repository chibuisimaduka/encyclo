class RatingsController < ApplicationController

  # Updates the rating and rankable rank using a Bayesian mean estimate 
  def update
    @rankable = find_polymorphic_association
    @rating = @rankable.ratings.find_by_user_id(current_user.id) || @rankable.ratings.build
    @rating.user_id = current_user.id unless @rating.user_id
    before_value = @rating.value || 0
    @rating.value = params[:rating][:value].to_f
    
    min_votes = 1
    # We can't keep track of the real overall mean, because it would mean
    # that if we change a rating, all the other ranks should change as well.
    mean = 7.0
    ratings_rank_norm = 1.0 / 10.0
      
    if @rating.persisted?
      rank = (@rankable.ratings.map(&:value).sum - before_value + @rating.value + (mean * min_votes)) / (@rankable.ratings.size + min_votes)
    else
      rank = (@rankable.ratings.map(&:value).sum + @rating.value + (mean * min_votes)) / (@rankable.ratings.size + 1 + min_votes)
    end

    @rankable.rank = rank * ratings_rank_norm
    Rating.transaction do
      if @rankable.class.name == 'Entity'
        EntityAdviserClient.update_entity_rank(@rankable.id, @rankable.rank, @rankable.parent_id, current_user.id, @rating.value)
      end
      @rating.save! if @rating.persisted?
      @rankable.save!
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

class RatingsController < ApplicationController
 
  def update
    @rankable = find_polymorphic_association
    @rating = @rankable.ratings.find_or_initialize_by_user_id(current_user.id)
    value = params[:rating][:value].to_f
    before_value = @rating.value || 0
    #begin
      Rating.transaction do
        min_votes = 1
        ratings_rank_norm = 1.0 / 10.0
       
        if @rating.persisted?
          rank = calculate_updated_rank(@rankable.ratings.map(&:value).sum, before_value,
                    @rankable.rank / ratings_rank_norm, min_votes, value, @rankable.ratings.size)
        else
          if @rankable.ratings.blank?
            if @rating.rankable_type == 'Entity'
              # Entity are ranked by categories
              rating_ref = Rating.joins(:entity).where("entities.parent_id = ?", @rankable.parent_id).first
            else
              rating_ref = Rating.where("rankable_type = ?", @rating.rankable_type).first
            end
            if rating_ref
              rankable_ref = rating_ref.rankable
              rank = (value + ((rankable_ref.rank * (rankable_ref.ratings.size + min_votes)) - rankable_ref.ratings.map(&:value).sum)) / (min_votes + 1)
            else
              rank = (value + (value * min_votes)) / (min_votes + 1)
            end
          else
            rank = calculate_added_rank(@rankable.ratings.map(&:value).sum, @rankable.rank / ratings_rank_norm, min_votes, value, @rankable.ratings.size)
          end
        end

        @rating.update_attributes!(value: value)
        @rankable.update_attributes!(rank: rank * ratings_rank_norm)
      end
    #rescue
      # TODO
    #end
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

private
  # After awesome algebra manipulations, to add a value to a Bayesian mean estimate:
  # W = (T + r + (w(v + m) - T)) / (v + 1 + m)
  # where T = sum of all old ratings for the entity, w = old ratings rank, m = minimum of votes required, r = new rating value, v = number of votes before
  # Note: T = Rv, where R = average rating, v = number of ratings
  def calculate_added_rank(sum, old_rank, min_votes, rating, num_votes_before)
    (sum + rating + ((old_rank * (num_votes_before + min_votes)) - sum)) / (num_votes_before + 1 + min_votes)
  end

  # To update a value to a Bayesian mean estimate :
  # W = (T - r0 + r + (w(v + m) - T)) / (v + m), where r0 is the old rating
  # where T = sum of all old ratings for the entity, w = old ratings rank, m = minimum of votes required,
  #   r = new rating value, v = number of votes before, r0 = old rating value
  # Note: T = Rv, where R = average rating, v = number of ratings
  def calculate_updated_rank(sum, old_rating, old_rank, min_votes, rating, num_votes_before)
    (sum - old_rating + rating + ((old_rank * (num_votes_before + min_votes)) - sum)) / (num_votes_before + min_votes)
  end

end

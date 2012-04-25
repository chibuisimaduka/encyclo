namespace :entities do

  task :set_content_size_rank do
    `python script/freebase/set_content_size_rank.py`
  end

  # The rank is calculated using a combination of user ratings and content rank.
  # The ratings rank is calculated using a Bayesian estimate mean.
  task :rank => [:init, :set_content_size_rank] do
    Entity.where("id IN (SELECT DISTINCT parent_id from entities)").each do |entity|
      # OPTIMIZE: Merge the two following queries.
      ratings_sum = Rating.joins("entities").where("entities.parent_id = ?", entity.id).sum("value")
      ratings_count = Rating.joins("entities").where("entities.parent_id = ?", entity.id).count
      entities_count = entity.entities.count
      valid_probability = 0.4

      min_votes = (ratings_sum / entities_count * valid_probability)

      mean = ratings_sum / ratings_count
      e.entities.each do |e|
        ratings_score = (e.ratings.sum("value") + (mean * min_votes)) / (e.ratings.count + min_votes)
        if ratings_score
          score = ratings_score
        else
          # content_rank = (e.all_associations.map {|a| a.associated_entity.content_size_rank}).sum
          score = e.content_size_rank
        end
      end
    end
  end
end

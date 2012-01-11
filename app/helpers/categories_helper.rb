module CategoriesHelper
  def ranking(category)
    Ranking.find_by_category_id_and_user_id(category.id, current_user.id)
  end
  def rating_for(record_id, ranking_id)
    element = RankingElement.find_by_ranking_id_and_record_id(ranking_id, record_id)
	 element.nil? ? nil : element.rating
  end
end

class RankingTypesController < ApplicationController

  def update
	 self.ranking_type = (params[:ranking_type] or (current_user ? RankingType::USER : RankingType::TOP))
	 redirect_to :back
  end

end

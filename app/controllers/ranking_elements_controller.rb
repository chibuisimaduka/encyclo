class RankingElementsController < ApplicationController
 
  # TODO: Test this..
  def rank
    @ranking = Ranking.find_or_create_by_user_id_and_tag_id(current_user.id, params[:tag_id])
    raise "missing record_id" unless params[:record_id]

    @elem = @ranking.ranking_elements.find_or_initialize_by_record_id(params[:record_id])
    @elem.record.update_attribute :rank, (((@elem.record.rank || 0) * @elem.record.num_votes) - (@elem.rating || 0) + params[:rating].to_f) / (@elem.record.num_votes += 1)
    @elem.rating = params[:rating]
    @elem.save!
  end

  # TODO: Test this..
  def destroy
    @record = RankingElement.find params[:id]
	 if @record
      @record.record.update_attribute :rank, ((@record.record.rank * @record.record.num_votes) - @record.rating) / (@record.record.num_votes -= 1) if @record.record.rank
	   @record.destroy
	 end
	 redirect_to :back
  end

  def rank_up
    raise "TODO"
    #begin
    @ranking_element = Ranking.find(params[:ranking_id]).ranking_elements.find_by_record_id(params[:record_id])
	 @ranking_element.move_higher
    #rescue
	 #  @ranking_element = @ranking.ranking_elements.create!(:record_id => params[:record_id])
	 #	@ranking_element.ranking.insert @ranking_element
	 #end
	 redirect_to :back
  end

  def rank_down
    raise "TODO"
    @ranking_element = Ranking.find(params[:ranking_id]).ranking_elements.find_by_record_id(params[:record_id])
	 @ranking_element.move_lower
	 redirect_to :back
  end

  def sort
    raise "TODO"
    raise "Missing ranking id" unless params[:ranking_id]
    params[params[:elements]].each_with_index do |value, index|
      RankingElement.update_all(['position=?', index+1], ['ranking_id=? AND record_id=?', params[:ranking_id], value])
	 end
    render :update do |page|
      # FIXME: Only do it once, not for every one..
      params[params[:elements]].each_with_index do |record_id, index|
        page.replace_html "ranking_#{params[:ranking_id]}_record_#{record_id}", :partial => "ranking_elements/ranking_element",
            :locals => {:ranking_id => params[:ranking_id], :record_id => record_id, :position => index+1}
      end
    end
  end

end

class DeleteRequestsController < ApplicationController

  def create
    @destroyable = find_polymorphic_association
    @delete_request = @destroyable.build_delete_request
    @delete_request.concurring_users << current_user
    @delete_request.deleted = true if @delete_request.considered_deleted?
    if !@delete_request.save
      flash[:notice] = "An error has occured while creating delete request."
    end
	 redirect_to :back
  end

  def remove_concurring_user
    @delete_request = DeleteRequest.find(params[:id])
    @delete_request.concurring_users.delete(current_user)
    @delete_request.destroy unless @delete_request.valid?
	 redirect_to :back
  end

  def remove_opposing_user
    @delete_request = DeleteRequest.find(params[:id])
    @delete_request.opposing_users.delete(current_user)
    @delete_request.update_attributes(deleted: true) if @delete_request.considered_deleted?
	 redirect_to :back
  end

  def add_concurring_user
    @delete_request = DeleteRequest.find(params[:id])
    @delete_request.concurring_users << current_user
    @delete_request.update_attributes(deleted: true) if @delete_request.considered_deleted?
	 redirect_to :back
  end
  
  def add_opposing_user
    @delete_request = DeleteRequest.find(params[:id])
    @delete_request.opposing_users << current_user
    # TODO: Delete delete request if most thinks it should
	 redirect_to :back
  end

end

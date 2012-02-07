class DeleteRequestsController < ApplicationController

  def create
    @delete_request = DeleteRequest.new
    @delete_request.entity_id = params[:entity_id]
    @delete_request.concurring_users << current_user
    @delete_request.save!
	 redirect_to @delete_request.entity.parent ? @delete_request.entity.parent : root_path
  end

  def remove_concurring_user
    @delete_request = DeleteRequest.find(params[:id])
    @delete_request.concurring_users.delete(current_user)
    @delete_request.destroy unless @delete_request.valid?
	 redirect_to @delete_request.entity
  end

  def remove_opposing_user
    @delete_request = DeleteRequest.find(params[:id])
    @delete_request.opposing_users.delete(current_user)
    # TODO: Delete entity if most thinks it should
	 redirect_to @delete_request.entity
  end

  def add_concurring_user
    @delete_request = DeleteRequest.find(params[:id])
    @delete_request.concurring_users << current_user
    # TODO: Delete entity if most thinks it should
	 redirect_to @delete_request.entity
  end
  
  def add_opposing_user
    @delete_request = DeleteRequest.find(params[:id])
    @delete_request.opposing_users << current_user
    # TODO: Delete delete request if most thinks it should
	 redirect_to @delete_request.entity
  end
end

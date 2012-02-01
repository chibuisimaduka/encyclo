class AssociationsController < ApplicationController
  respond_to :html, :json
  
  def create
    @association = Association.new(params[:association])
    @association.save!
    redirect_to :back
  end

  def destroy
    @association = Association.find(params[:id])
    @association.destroy
    redirect_to :back
  end

end

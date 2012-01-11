class ListingTypesController < ApplicationController

  def update
	 self.listing_type = (ListingType::LISTING_TYPES[params[:listing_type]] or ListingType::EXPANDED)
	 redirect_to :back
  end

end

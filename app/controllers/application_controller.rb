class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  helper_method :opened_tags
  helper_method :listing_type
  helper_method :ranking_type

  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def listing_type
    @listing_type ||= (ListingType::LISTING_TYPES[session[:listing_type_id].to_s] or ListingType::ENTITY_LIST)
  end

  def listing_type=(listing_type)
    @listing_type = listing_type
	 session[:listing_type_id] = listing_type.id
  end

  def ranking_type
    @ranking_type ||= session[:ranking_type].to_s
  end

  def ranking_type=(ranking_type)
    @ranking_type = ranking_type
    session[:ranking_type] = ranking_type
  end

  def opened_tags
    session[:opened_tag] ||= {}
  end
end

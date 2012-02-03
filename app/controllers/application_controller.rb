class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  helper_method :opened_entities
  helper_method :listing_type
  helper_method :ranking_type
  helper_method :documents_filter
  helper_method :language_filter
  helper_method :current_language

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

  def opened_entities
    session[:opened_entities] ||= {}
  end

  def language_filter
    session[:language_filter] ||= default_language_filter
  end

  def default_language_filter
    filterer = Filterer.new(:id)
    filterer.id = Language.find_by_name("english").id
    filterer
  end

  def documents_filter
    session[:documents_filter] ||= Filterer.new(:language_id, :document_type_id)
  end

  def current_language
    session[:current_language] = session[:current_language] ? (session[:current_language].id == language_filter.id ? session[:current_language] : Language.find(language_filter.id)) : Language.find_by_name("english")
  end
end

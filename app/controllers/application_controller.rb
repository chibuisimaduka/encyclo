class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  helper_method :opened_entities
  helper_method :listing_type
  helper_method :ranking_type
  helper_method :documents_filter
  helper_method :language_filter
  helper_method :current_language

  helper_method :rating_for # FIXME: TMP
  
  def rating_for(rankable)
    rankable.ratings.find_by_user_id(current_user.id)
  end

protected
  
  def find_polymorphic_association
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end

private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    @current_user ||= User.find_or_create_by_email_and_is_ip_address(request.remote_ip, true)
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

class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  helper_method :document_type_filter
  helper_method :current_language
  helper_method :data_mode?

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

  def document_type_filter
    session[:document_type_filter]
  end

  def current_language
    session[:current_language] ||= Language.find_by_name("english")
  end

  def data_mode?
    true
  end
end

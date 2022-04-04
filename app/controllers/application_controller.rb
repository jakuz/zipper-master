class ApplicationController < ActionController::Base

  before_action do
    ActiveStorage::Current.host = 'http://localhost:3000' \
      if ActiveStorage::Current.host.blank?
  end

  helper_method :current_user
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def authorize
    return unless current_user.nil?
    
    flash[:alert] = "Musisz się zalogować, aby uzyskać dostęp do tej strony."
    redirect_to login_path
  end

  def log_in(user)
    session[:user_id] = user.id.to_s
  end

end

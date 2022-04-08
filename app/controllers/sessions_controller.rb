class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:login][:email].downcase)
    
    if user && user.authenticate(params[:login][:password]) 
      log_in user
      flash[:notice] = "Pomyślnie zalogowano użytkownika"
      redirect_to root_path
    else
      flash.now[:alert] = "Błędny email i/lub hasło. Spróbuj ponownie."
      render :new
    end
  end

  def destroy
    session.delete(:user_id)
    flash[:notice] = "Pomyślnie wylogowano użytkownika"
    redirect_to login_path
  end
end

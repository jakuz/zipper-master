class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.email.downcase!
    
    if @user.save
      flash_registration_success
      log_in @user
      redirect_to root_path
    else
      log_error_and_flash_registration_failure
      @user = User.new
      render :new
    end
  end

private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def flash_registration_success
    flash[:notice] = "Konto utworzone pomyślnie"
  end

  def log_error_and_flash_registration_failure
    logger.error "Could not create new user: #{@user.inspect}"
    logger.debug "#{@user.errors.map{ |e| e.full_message }}"
    flash.now[:alert] = "Coś poszło nie tak... Upewnij się, czy poprawnie wpisałeś email i hasło."
  end
end

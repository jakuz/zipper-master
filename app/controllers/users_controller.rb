class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.email.downcase!
    
    if @user.save
      flash[:notice] = "Konto utworzone pomyślnie"
      log_in @user
      redirect_to root_path
    else
      flash.now[:alert] = "Coś poszło nie tak... Upewnij się, czy poprawnie wpisałeś email i hasło."
      @user = User.new
      render :new
    end
  end

private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

end

class SessionsController < ApplicationController
  before_action :check_login, only: :new

  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      if user.activated?
        login user
        params[:session][:remember_me] == Settings.remember ? remember(user) :
          forget(user)
        redirect_back_or user
      else
        flash[:warning] = t "login.noactive"
        redirect_to login_path
      end
    else
      flash.now[:danger] = t "login.fail"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end
end

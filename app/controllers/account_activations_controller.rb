class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      login user
      flash[:success] = t "mail.active_ok"
      redirect_to user
    else
      flash[:danger] = t "mail.active_fail"
      redirect_to root_url
    end
  end
end

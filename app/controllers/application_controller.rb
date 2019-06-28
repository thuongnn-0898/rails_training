class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  private

  def load_user
    @user = User.find_by(email: params[:email])
    return if @user || not_found
    # render html: t("user.notfound", id: params[:id])
  end

  def not_found
    render file: "#{Rails.root}/public/404", layout: false, status: :not_found
  end

  def check_login
    return unless logged_in?
    redirect_to root_path
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = t "login.nologin"
      redirect_to login_url
    end
  end
end

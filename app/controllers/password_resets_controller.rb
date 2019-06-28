class PasswordResetsController < ApplicationController
  # before_action :get_user, only: [:edit, :update]
  # before_action :valid_user, only: [:edit, :update]
  # before_action :check_expiration, only: [:edit, :update]
  before_action :load_user, :valid_user, :check_expiration, only: [:edit, :update]

  def new; end

  def edit; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "reset_password.send_message"
      redirect_to root_url
    else
      flash.now[:danger] = t("reset_password.send_fail")
      render :new
    end
  end

  def update
    # password empty
    if params[:user][:password].empty?
      @user.errors.add(:password, t("reset_password.password_empty"))
      render :edit
    # update thanh cong
    elsif @user.update_attributes(user_params)
      login @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = t "reset_password.succcess"
      redirect_to @user
    else
      # sai password hay gi gi do
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def load_user
    @user = User.find_by(email: params[:email])
    return if @user
    render html: t("reset_password.not_found", email: params[:email])
  end

  # Confirms a valid user.
  def valid_user
    unless @user.activated? && @user.authenticated?(:reset, params[:id])
      redirect_to root_url
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = t "reset_password.expiration"
      redirect_to new_password_reset_url
    end
  end
end

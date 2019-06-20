class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = User.find_by id: params[:id]
    return @user.nil?
    render html: "not found"
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = t("auth.success", email: @user.email)
      redirect_to @user
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password, :password_confirmation
  end
end

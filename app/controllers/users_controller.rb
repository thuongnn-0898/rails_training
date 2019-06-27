class UsersController < ApplicationController
  before_action :logged_in_user, except: [:new, :create]
  # before_action :load_user, only: [:edit, :update, :show, :destroy]
  before_action :load_user, except: [:index, :create, :new]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.activated.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def show
    redirect_to(root_url) && return unless current_user.activated?
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = t "auth.create"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if user.update_attributes user_params
      flash[:success] = t("user.profile_update")
      redirect_to user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t("user.delete_success", email: @user.email)
    else
      flash[:danger] = t "user.detele_fail"
    end
    redirect_to users_url
  end

  private

  def load_user
    @user = User.find_by(id: params[:id])
    return if @user
    render html: t("user.notfound", id: params[:id])
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = t("login.nologin")
      redirect_to login_url
    end
  end

  def correct_user
    # @user = User.find_by id: params[:id]
    redirect_to root_url unless current_user? @user
  end

  def admin_user
    return if current_user.admin?
    flash[:danger] = t("user.detele_fail")
    redirect_to(root_url)
  end

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end
end

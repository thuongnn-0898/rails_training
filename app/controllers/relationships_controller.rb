class RelationshipsController < ApplicationController
  before_action :logged_in_user
  before_action :find_relationship_by_user, only: :destroy
  before_action :find_user_by_followed, only: :create
  def create
    # user = User.find_by(id: params[:followed_id])
    # return not_found unless user
    current_user.follow @user
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  def destroy
    # user = Relationship.find(params[:id]).followed
    # return not_found unless user
    @user = @user.followed
    current_user.unfollow @user
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  private

  def find_relationship_by_user
    @user = Relationship.find_by id: params[:id]
    # return if @user || not_found
    user_invalid @user
  end

  def find_user_by_followed
    @user = User.find_by id: params[:followed_id]
    user_invalid @user
  end

  def user_invalid user
    unless user
      flash[:danger] = t("relationships.not_found")
      redirect_to root_path
    end
  end
end

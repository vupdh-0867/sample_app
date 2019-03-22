class RelationshipsController < ApplicationController
  before_action :logged_in_user
  before_action :load_user, only: :create
  before_action :load_relationship, only: :destroy

  def create
    current_user.follow @user
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  def destroy
    @user = @user.followed
    current_user.unfollow @user
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  private

  def load_user
    @user = User.find_by id: params[:followed_id]
    return if @user
    flash[:danger] = t "controllers.relationships_controller.user_not_available"
    redirect_to current_user
  end

  def load_relationship
    @user = Relationship.find_by(id: params[:id])
    return if @user
    flash[:danger] = t "controllers.relationships_controller.user_not_available"
    redirect_to current_user
  end
end

class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :load_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy
  #caches_action :show

  def show
    if @user
      sleep 5
      @microposts = @user.microposts.newest.paginate page: params[:page],
        per_page: Settings.app.models.micropost.microposts_per_page
    else
      flash[:danger] = t "controllers.users_controller.user_not_found"
      redirect_to :root
    end
  end

  def index
    @users = User.paginate page: params[:page],
      per_page: Settings.app.models.user.users_per_page
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "controllers.users_controller.account_activation"
      redirect_to root_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t "controllers.users_controller.update_success"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "controllers.users_controller.delete_success"
      redirect_to users_path
    else
      flash[:danger] = t "controllers.users_controller.delete_fail"
    end
  end

  def following
    @title = t "controllers.users_controller.following"
    @users = @user.following.paginate page: params[:page],
      per_page: Settings.app.models.user.following_per_page
    render :show_follow
  end

  def followers
    @title = t "controllers.users_controller.followers"
    @users = @user.followers.paginate page: params[:page],
      per_page: Settings.app.models.user.followers_per_page
    render :show_follow
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def correct_user
    redirect_to root_path unless @user == current_user
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t "controllers.users_controller.user_not_found"
    redirect_to login_path
  end

  def admin_user
    return if current_user.admin?
    redirect_to root_path
  end
end

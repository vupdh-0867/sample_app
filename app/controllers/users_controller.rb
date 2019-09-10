class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :load_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy
  before_action :befact, only: :show
  after_action :aftact, only: :show
  caches_page :show
  # caches_action :show
  # etag do
  #    1  if %w("show").include? params[:action]
  # end

  def show
    if @user
      #fresh_when last_modified: @user.updated_at
      #expires_in 2.minutes
      #response.headers["Expires"] = 1.minutes.from_now.httpdate
      puts "\e[31minside action\e[0m"
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

  def edit
    puts "\e[31minside action\e[0m"
  end

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

  def befact
    puts "\e[32mbefore action\e[0m"
  end

  def aftact
    puts "\e[32mafter action\e[0m"
  end

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
    return if h.admin?
    redirect_to root_path
  end
end

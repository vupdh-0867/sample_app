class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :load_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def show
    return if @user
    flash[:danger] = t "controllers.users_controller.user_not_found"
    redirect_to :root
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

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t "controllers.users_controller.not_logged_in_yet"
    redirect_to login_path
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

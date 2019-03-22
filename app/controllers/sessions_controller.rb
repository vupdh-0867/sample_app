class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user&.authenticate params[:session][:password]
      handle_user_is_activated_or_not user
    else
      flash.now[:danger] =
        t "controllers.sessions_controller.login_fail_message"
      render :new
    end
  end

  def handle_user_is_activated_or_not user
    if user.activated?
      log_in user
      remember_or_forget user
      redirect_back_or user
    else
      flash[:warning] = t "controllers.sessions_controller.unactivated_account"
      redirect_to root_path
    end
  end

  def remember_or_forget user
    if params[:session][:remember_me] == Settings.app.yes_remember_me
      remember(user)
    else
      forget(user)
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end
end

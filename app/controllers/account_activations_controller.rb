class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.update activated: true, activated_at: Time.zone.now
      log_in user
      flash[:success] =
        t "controllers.account_activations_controller.activated_success"
      redirect_to user
    else
      flash[:danger] =
        t "controllers.account_activations_controller.activated_fail"
      redirect_to root_path
    end
  end
end

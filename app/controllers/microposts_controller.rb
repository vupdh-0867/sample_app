class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :load_micropost, only: :destroy

  def create
    @micropost = current_user.microposts.build micropost_params
    if @micropost.save
      flash[:success] = t "controllers.microposts_controller.created_success"
      redirect_to root_path
    else
      flash.now[:danger] = t "controllers.microposts_controller.created_fail"
      @feed_items = []
      render "static_pages/home"
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t "controllers.microposts_controller.deleted_success"
    else
      flash[:danger] = t "controllers.microposts_controller.deleted_fail"
    end
    redirect_to request.referrer || root_path
  end

  private

  def micropost_params
    params.require(:micropost).permit :content, :picture
  end

  def load_micropost
    @micropost = current_user.microposts.find_by(id: params[:id])
    return if @micropost
    flash[:danger] = t "controllers.microposts_controller.user_not_found"
    redirect_to root_path
  end
end

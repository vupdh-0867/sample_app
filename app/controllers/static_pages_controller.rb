class StaticPagesController < ApplicationController
  #caches_page :home

  def home
    handle_data
    return unless logged_in?
    @micropost  = current_user.microposts.build
    @feed_items = current_user.feed.paginate page: params[:page],
      per_page: Settings.app.models.micropost.microposts_per_page
  end

  def help; end

  def about; end

  def contact; end

  private

  def handle_data
    sleep 5
  end
end

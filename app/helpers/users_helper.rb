module UsersHelper
  # Returns the Gravatar for the given user.
  def gravatar_for user, options = {
    size: Settings.app.helper.users_helper.avatar_size
  }
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end

  def find_user_followed_by_id id
    current_user.active_relationships.find_by followed_id: id
  end
end

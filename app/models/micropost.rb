class Micropost < ApplicationRecord
  belongs_to :user
  scope :newest, ->{order created_at: :desc}
  scope :by_user_id, ->(user_id){where "user_id = ?", user_id}
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.app.models.micropost.content_max_length}
  validate  :picture_size

  private

  def picture_size
    errors.add(:picture, I18n.t("micropost.image_sizing_error")) if
      picture.size > Settings.app.models.micropost.picture_max_size.megabytes
  end
end

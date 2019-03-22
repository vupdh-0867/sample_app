class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  before_save{email.downcase!}
  has_secure_password
  validates :email, presence: true,
    length: {maximum: Settings.app.models.user.email_max_length},
    format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :name, presence: true,
    length: {maximum: Settings.app.models.user.name_max_length}
  validates :password, presence: true,
    length: {minimum: Settings.app.models.user.password_max_length}
end

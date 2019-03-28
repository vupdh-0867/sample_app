class User < ApplicationRecord
  attr_accessor :remember_token
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  before_save{email.downcase!}
  has_secure_password
  validates :email, presence: true,
    length: {maximum: Settings.app.models.user.email_max_length},
    format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :name, presence: true,
    length: {maximum: Settings.app.models.user.name_max_length}
  validates :password, presence: true,
    length: {minimum: Settings.app.models.user.password_max_length},
    allow_nil: true

  def self.digest string
    BCrypt::Password.create(string, cost: get_cost)
  end

  def get_cost
    return BCrypt::Engine.min_cost if ActiveModel::SecurePassword.min_cost
    BCrypt::Engine.cost
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update remember_digest: User.digest(remember_token)
  end

  def authenticated? remember_token
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update remember_digest: nil
  end
end

class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
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
    BCrypt::Password.create(string, cost: User.get_cost)
  end

  def self.get_cost
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

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update remember_digest: nil
  end

  def activate
    update_attributes :activated, true
    update_attributes :activated_at, Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update reset_digest: User.digest(reset_token)
    update reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.app.models.user.reset_password_limit.hours.ago
  end

  def reset_password user_params
    if user_params[:password].empty?
      errors.add :password,
        I18n.t("controllers.password_resets_controller.password_empty")
      return false
    end
    update_attributes user_params
    reset_sent_at < 10.hours.ago
  end

  def feed
    Micropost.by_user_id(id).newest
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    suser_idelf.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end

class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name,  presence: true, length: {maximum: Settings.max_val}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: Settings.max_val},
  format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  has_secure_password
  validates :password, presence: true, length: {minimum: Settings.min_val},
    allow_nil: true
  scope :activated, ->{where activated: true}
  class << self
    def digest string
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # tra ve ngau nhien 1 ma~ token
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    # khoi tao gia tri cho remember_token tu ham` random token tren
    self.remember_token = User.new_token
    # udpate gia tri cho remember_disgest trong dtb
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # so sánh mã remember trong dtb với rêmmber  token duoc truyen vao
  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false unless digest
    BCrypt::Password.new(digest).is_password?(token)
  end

  # active account
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
    # update_attribute(:activated, true)
    # update_attribute(:activated_at, Time.zone.now)
  end

  # sendmail
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def create_reset_digest
    # tao 1 ma toke tu` ham` new_token khai bao tu truoc
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    # update_attribute(:reset_digest,  User.digest(reset_token))
    # update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.expired.minutes.ago
  end

  def feed
    Micropost.find_by_id(id)
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end

class User < ApplicationRecord
  attr_accessor :remember_token
  before_save{self.email = email.downcase}
  validates :name,  presence: true, length: {maximum: Settings.max_val}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: Settings.max_val},
    format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  has_secure_password
  validates :password, presence: true, length: {minimum: Settings.min_val}

  class << self
    def digest string
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine::cost
      BCrypt::Password.create(string, cost: cost)
    end

    #tra ve ngau nhien 1 ma~ token
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    #khoi tao gia tri cho remember_token tu ham` random token tren
    self.remember_token = User.new_token
    #udpate gia tri cho remember_disgest trong dtb
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  #so sánh mã remember trong dtb với rêmmber  token duoc truyen vao
  def authenticated? remember_token
    return false unless remember_digest
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end
end

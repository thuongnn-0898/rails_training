class Micropost < ApplicationRecord
  belongs_to :user
  # default_scope ->{order(created_at: :desc)}
  scope :find_by_id, ->(user_id){where(user_id: user_id)}
  scope :order_by, ->{order created_at: :desc}
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: Settings.microposts.max_val}
  validate  :picture_size

  private

  # Validates the size of an uploaded picture.
  def picture_size
    if picture.size > Settings.picture_size.megabytes
      errors.add(:picture, t("micropost.upload", Settings.picture_size))
    end
  end
end

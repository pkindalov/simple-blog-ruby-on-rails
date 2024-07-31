# frozen_string_literal: true
class User < ApplicationRecord
  has_one_attached :avatar
  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post
  has_many :comments, dependent: :destroy
  # users to received notifications
  has_many :received_notifications, class_name: 'Notification', foreign_key: 'recipient_id'
  # permit users to generate notifications
  has_many :sent_notifications, class_name: 'Notification', foreign_key: 'actor_id'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def profile_photo
    if avatar.attached?
      avatar
    else
      'default_image.png'
    end
  end
end

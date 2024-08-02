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

  # Следващи потребители
  has_many :active_follows, class_name: 'Follow', foreign_key: 'follower_id', dependent: :destroy
  has_many :following, through: :active_follows, source: :followed

  # Последователи
  has_many :passive_follows, class_name: 'Follow', foreign_key: 'followed_id', dependent: :destroy
  has_many :followers, through: :passive_follows, source: :follower

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

  # Метод за следване на потребител
  def follow(other_user)
    active_follows.create(followed_id: other_user.id) unless following?(other_user)
  end

  # Метод за спиране на следване
  def unfollow(other_user)
    active_follows.find_by(followed_id: other_user.id).destroy if following?(other_user)
  end

  # Проверка дали следва даден потребител
  def following?(other_user)
    following.include?(other_user)
  end
end

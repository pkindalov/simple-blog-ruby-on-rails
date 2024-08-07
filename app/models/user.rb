# frozen_string_literal: true

class User < ApplicationRecord
  has_one_attached :avatar
  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post
  has_many :comments, dependent: :destroy
  # Users to receive notifications
  has_many :received_notifications, class_name: 'Notification', foreign_key: 'recipient_id'
  # Permit users to generate notifications
  has_many :sent_notifications, class_name: 'Notification', foreign_key: 'actor_id'

  # Следващи потребители
  has_many :active_follows, class_name: 'Follow', foreign_key: 'follower_id', dependent: :destroy
  has_many :following, through: :active_follows, source: :followed

  # Последователи
  has_many :passive_follows, class_name: 'Follow', foreign_key: 'followed_id', dependent: :destroy
  has_many :followers, through: :passive_follows, source: :follower

  has_many :active_blocks, class_name: 'Block', foreign_key: 'blocker_id', dependent: :destroy
  has_many :blocked_users, through: :active_blocks, source: :blocked

  has_many :passive_blocks, class_name: 'Block', foreign_key: 'blocked_id', dependent: :destroy
  has_many :blockers, through: :passive_blocks, source: :blocker

  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'receiver_id'

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
    follow = active_follows.find_by(followed_id: other_user.id)
    follow&.destroy
    follow # Връща Follow обекта преди унищожаването
  end

  # Проверка дали следва даден потребител
  def following?(other_user)
    following.include?(other_user)
  end

  # Метод за блокиране на потребител
  def block(other_user)
    transaction do
      active_blocks.create!(blocked_id: other_user.id) unless blocking?(other_user)
      unfollow(other_user) if following?(other_user) # Unfollow, ако следва този потребител
    end
  end

  # Метод за деблокиране на потребител
  def unblock(other_user)
    active_blocks.find_by(blocked_id: other_user.id)&.destroy
  end

  # Проверка дали блокира даден потребител
  def blocking?(other_user)
    blocked_users.include?(other_user)
  end

  def popularity_score
    # Изчисляване на броя харесвания за всички постове на потребителя
    likes_count = posts.joins("LEFT JOIN likes ON likes.likeable_id = posts.id AND likes.likeable_type = 'Post'")
                       .count("likes.id")

    # Изчисляване на броя коментари за всички постове на потребителя
    comments_count = posts.joins(:comments).count("comments.id")

    # Изчисляване на общия брой гледания и сваляния на PDF
    views_and_downloads = posts.sum("views_count + downloaded_as_pdf")

    # Изчисляване на общата популярност
    (3 * likes_count) + (2 * comments_count) + views_and_downloads
  end

  def can_message?(other_user)
    following.include?(other_user) && other_user.following.include?(self) && !blocking?(other_user) && !other_user.blocking?(self)
  end

  # Метод за извличане на взаимно следваните потребители
  def mutual_following
    following & followers
  end
end

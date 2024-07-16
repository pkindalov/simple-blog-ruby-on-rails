# frozen_string_literal: true
class User < ApplicationRecord
  has_one_attached :avatar
  has_many :posts, dependent: :destroy
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

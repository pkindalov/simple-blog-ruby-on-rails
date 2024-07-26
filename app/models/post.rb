# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :user
  # has_one_attached :photo
  has_many_attached :photos
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likers, through: :likes, source: :user
end

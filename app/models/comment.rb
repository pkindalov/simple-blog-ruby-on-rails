# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many :likes, as: :likeable, dependent: :destroy
end

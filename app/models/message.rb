# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  validates :content, presence: true
  validate :sender_can_message_receiver

  scope :unread, -> { where(read: false) }

  private

  def sender_can_message_receiver
    unless sender.can_message?(receiver)
      errors.add(:receiver, 'cannot be messaged.')
    end
  end

  def mark_as_read
    update(read: true)
  end

  def self.between(user1, user2)
    where(sender: user1, receiver: user2).or(where(sender: user2, receiver: user1))
  end
end

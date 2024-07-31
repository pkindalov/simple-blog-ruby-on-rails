class Notification < ApplicationRecord
  # Асоциации
  belongs_to :recipient, class_name: 'User'
  belongs_to :actor, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  # Scope за непрочетени нотификации
  scope :unread, -> { where(read_at: nil) }
end

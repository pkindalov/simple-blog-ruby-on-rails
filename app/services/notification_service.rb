# frozen_string_literal: true

class NotificationService
  def self.notify(recipient:, actor:, action:, notifiable:)
    return if actor == recipient # Не изпраща нотификация, ако действието е извършено от същия потребител

    Notification.create(
      recipient: recipient,
      actor: actor,
      action: action,
      notifiable: notifiable
    )
  end
end

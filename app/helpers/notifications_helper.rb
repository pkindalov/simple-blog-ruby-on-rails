# frozen_string_literal: true
# module NotificationsHelper
#   def notification_action(notification)
#     actor_email = notification.actor.email # Асумирам, че `actor` е асоцииран с Notification модела
#     action = case notification.action
#              when 'liked'
#                "liked your #{notification.notifiable_type.downcase}"
#              when 'commented'
#                "commented on your #{notification.notifiable_type.downcase}"
#              else
#                "made an action on your #{notification.notifiable_type.downcase}"
#              end
#     "#{actor_email} #{action}"
#   end
# end

module NotificationsHelper
  def notification_action(notification)
    actor_email = notification.actor.email
    notifiable = notification.notifiable

    action_link = case notifiable
                  when Post
                    link_to "post", post_path(notifiable), class: 'notification-link'
                  when Comment
                    link_to truncate(notifiable.content, length: 50), post_path(notifiable.post), class: 'notification-link' # Truncate comment content to 50 characters
                  else
                    '#'
                  end

    action_description = case notification.action
                         when 'liked'
                           "👍 liked your #{notification.notifiable_type.downcase}"
                         when 'commented'
                           "🗣 commented on your #{notification.notifiable_type.downcase}"
                         when 'downloaded'
                           "💾 downloaded your #{notification.notifiable_type.downcase}"
                         when 'unliked'
                           "👎 unliked your #{notification.notifiable_type.downcase}"
                         else
                           "made an action on your #{notification.notifiable_type.downcase}"
                         end

    "#{actor_email} #{action_description} on #{action_link}".html_safe
  end
end



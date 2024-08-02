module NotificationsHelper
  def notification_action(notification)
    # Връзка към email-а на актьора с линк към неговия профил
    actor_email = link_to(notification.actor.email, user_profile_path(notification.actor), class: 'notification-link')
    notifiable = notification.notifiable

    # Линк към действие, ако е приложимо
    action_link = case notifiable
                  when Post
                    link_to 'post', post_path(notifiable), class: 'notification-link'
                  when Comment
                    link_to truncate(notifiable.content, length: 50), post_path(notifiable.post), class: 'notification-link text-decoration-none'
                  when Follow
                    # В случай на следване, можем да върнем линк към профила на следваното лице
                    link_to notifiable.followed.email, user_profile_path(notifiable.followed), class: 'notification-link'
                  else
                    '#'
                  end

    # Описание на действието
    action_description = case notification.action
                         when 'liked'
                           "👍 liked your #{notification.notifiable_type.downcase}"
                         when 'commented'
                           "🗣 commented on your #{notification.notifiable_type.downcase}"
                         when 'downloaded'
                           "💾 downloaded your #{notification.notifiable_type.downcase}"
                         when 'unliked'
                           "👎 unliked your #{notification.notifiable_type.downcase}"
                         when 'follow'
                           '🚶‍♀️ started following you on your profile '
                         when 'unfollow'
                           '🚶‍♀ stopped following you on your profile'
                         else
                           "made an action on your #{notification.notifiable_type.downcase}"
                         end

    "#{actor_email} #{action_description} on #{action_link}".html_safe
  end
end

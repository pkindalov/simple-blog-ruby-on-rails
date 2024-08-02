# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: %i[destroy mark_as_read mark_as_unread]

  def index
    @notifications = current_user.received_notifications
                                 .order(read_at: :asc, created_at: :desc)
                                 .paginate(page: params[:page], per_page: 5)
  end

  def destroy
    @notification.destroy
    redirect_to notifications_path, notice: 'Notification was successfully deleted.'
  end

  def mark_as_read
    @notification.update(read_at: Time.current)
    redirect_to notifications_path, notice: 'Notification marked as read.'
  end

  def mark_as_unread
    @notification.update(read_at: nil)
    redirect_to notifications_path, notice: 'Notification marked as unread.'
  end

  def mark_all_as_read
    current_user.received_notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: 'All notifications have been marked as read.'
  end

  def mark_all_as_unread
    # unread_notifications = current_user.received_notifications.readed
    # puts "Found #{unread_notifications.count} unread notifications"
    current_user.received_notifications.readed.update_all(read_at: nil)
    redirect_to notifications_path, notice: 'All notifications have been marked as unread.'
  end

  def delete_all
    current_user.received_notifications.unread.destroy_all
    redirect_to notifications_path, notice: 'All notifications deleted.'
  end

  private

  def set_notification
    @notification = Notification.find(params[:id])
  end
end

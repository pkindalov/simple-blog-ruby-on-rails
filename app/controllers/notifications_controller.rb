class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [:destroy, :mark_as_read]

  def index
    @notifications = current_user.received_notifications.paginate(:page => params[:page], :per_page => 2).order('created_at DESC')
  end

  def destroy
    @notification.destroy
    redirect_to notifications_path, notice: 'Notification was successfully deleted.'
  end

  def mark_as_read
    @notification.update(read_at: Time.current)
    redirect_to notifications_path, notice: 'Notification marked as read.'
  end

  def mark_all_as_read
    current_user.received_notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: 'All notifications have been marked as read.'
  end

  private

  def set_notification
    @notification = Notification.find(params[:id])
  end
end

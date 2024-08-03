class LikesController < ApplicationController
  include LikesHelper
  before_action :authenticate_user!
  before_action :find_likeable
  before_action :check_blocked, only: %i[create destroy]

  def create
    if already_liked?(current_user, @likeable)
      redirect_to request.referrer || root_path, alert: "You can't like more than once"
    else
      like = @likeable.likes.create(user_id: current_user.id)
      if like.persisted? && current_user != @likeable.user
        NotificationService.notify(
          recipient: @likeable.user,
          actor: current_user,
          action: 'liked',
          notifiable: @likeable
        )
      end
      redirect_to request.referrer || root_path, notice: "Liked successfully!"
    end
  end

  def destroy
    like = @likeable.likes.find_by(user_id: current_user.id)
    if like
      like.destroy
      NotificationService.notify(
        recipient: @likeable.user,
        actor: current_user,
        action: 'unliked',
        notifiable: @likeable
      )
      redirect_to request.referrer || root_path, notice: "Like removed."
    else
      redirect_to request.referrer || root_path, alert: "Like not found."
    end
  end

  private

  def find_likeable
    @likeable = Comment.find_by(id: params[:comment_id]) || Post.find_by(id: params[:post_id])
  end

  def check_blocked
    if @likeable.is_a?(Post) || @likeable.is_a?(Comment)
      author = @likeable.user
      if current_user.blocking?(author) || author.blocking?(current_user)
        redirect_to request.referrer || root_path, alert: 'You cannot like or unlike content from this user.'
      end
    end
  end
end

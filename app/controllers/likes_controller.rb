class LikesController < ApplicationController
  include LikesHelper
  before_action :find_likeable

  def create
    if already_liked?(current_user, @likeable)
      redirect_to request.referrer || root_path, alert: "You can't like more than once"
    else
      @likeable.likes.create(user_id: current_user.id)
      redirect_to request.referrer || root_path, notice: "Liked successfully!"
    end
  end

  def destroy
    like = @likeable.likes.find_by(user_id: current_user.id)
    if like
      like.destroy
      redirect_to request.referrer || root_path, notice: "Like removed."
    else
      redirect_to request.referrer || root_path, alert: "Like not found."
    end
  end

  private

  def find_likeable
    @likeable = Comment.find_by(id: params[:comment_id]) || Post.find_by(id: params[:post_id])
  end
end

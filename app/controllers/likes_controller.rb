# frozen_string_literal: true

class LikesController < ApplicationController
  before_action :find_post

  def create
    if already_liked?
      msg = "You can't like more than once"
    else
      @post.likes.create(user_id: current_user.id)
      msg = "Liked successfully!"
    end
    redirect_to post_path(@post), notice: msg
  end

  def destroy
    @like = @post.likes.find(params[:id])
    @like.destroy
    redirect_to post_path(@post)
  end

  private

  def find_post
    @post = Post.find(params[:post_id])
  end

  def already_liked?
    Like.where(user_id: current_user.id, post_id: params[:post_id]).exists?
  end
end

# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: %i[edit update destroy]
  before_action :check_blocked, only: %i[create edit update destroy]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to post_path(@post), notice: 'Comment was successfully added.'
    else
      redirect_to post_path(@post), alert: 'Error adding comment.'
    end
  end

  def edit
    # Логиката за редактиране е вече обработена от before_action
  end

  def update
    if @comment.update(comment_params)
      redirect_to post_path(@post), notice: 'Comment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @comment.destroy
    redirect_to post_path(@post), notice: 'Comment was successfully destroyed.'
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def check_blocked
    if current_user.blocking?(@post.user) || @post.user.blocking?(current_user)
      redirect_to post_path(@post), alert: 'You cannot interact with this post.'
    end
  end

  # if want user to edit or delete comments in blocked user's posts
  # def check_blocked
  #   if current_user.blocking?(@post.user) || @post.user.blocking?(current_user)
  #     if action_name.in?(%w[edit update destroy]) && @comment.user == current_user
  #       return # Разрешава редактиране и изтриване само на собствени коментари
  #     end
  #     redirect_to post_path(@post), alert: 'You cannot interact with this post.'
  #   end
  # end
end

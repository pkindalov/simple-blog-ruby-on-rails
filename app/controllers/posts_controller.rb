# frozen_string_literal: true
# require 'pp'

class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: %i[edit update destroy]

  def edit
    # Не е необходимо да вземаш поста, защото го вземаме в before_action
  end

  def show
    @post = Post.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Post not found'
  end

  def index
    @posts = Post.paginate(:page => params[:page], :per_page => 3).order('created_at DESC')
  end

  def create
    @post = current_user.posts.build(post_params) # Създаваме поста за текущия потребител
    # @post.photo.attach(params[:post][:photo]) if params[:post][:photo]

    # Rails.logger.debug "Post Params: #{post_params.inspect}"
    # Rails.logger.debug "Photo Param: #{params[:post][:photo].inspect}"

    @post.photo.attach(params[:post][:photo]) if params[:post][:photo].present?

    if @post.save
      redirect_to root_path, notice: 'Post was successfully created.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update
    @post = Post.find(params[:id])

    # Проверяваме дали има избрани снимки за изтриване
    # if params[:deleted_photo_ids].present?
    #   params[:deleted_photo_ids].each do |photo_id|
    #     photo = @post.photos.find_by(id: photo_id)
    #     photo&.purge
    #     puts 'deleted'
    #   end
    # end

    if @post.update(post_params.except(:photos))
      puts 'Post updated successfully'
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      puts 'Failed to update post'
      render :edit, alert: 'Post update failed.'
    end
  end

  def delete_photo
    @post = Post.find(params[:id])
    photo = @post.photos.find_by(id: params[:photo_id])

    if photo
      photo.purge
      flash[:notice] = 'The photo has been deleted'
    else
      flash[:alert] = 'The photo not found.'
    end

    redirect_to edit_post_path(@post)
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_post
    @post = current_user.posts.find(params[:id]) # Намираме поста само за текущия потребител
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Post could not be found.'
  end

  def post_params
    params.require(:post).permit(:title, :description, :post_date, photos: [])
  end
end

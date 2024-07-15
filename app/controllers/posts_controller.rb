class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:edit, :update, :destroy]

  def edit
    # Не е необходимо да вземаш поста, защото го вземаме в before_action
  end

  def create
    @post = current_user.posts.build(post_params)  # Създаваме поста за текущия потребител
    # @post.photo.attach(params[:post][:photo]) if params[:post][:photo]

    # Rails.logger.debug "Post Params: #{post_params.inspect}"
    # Rails.logger.debug "Photo Param: #{params[:post][:photo].inspect}"

    if params[:post][:photo].present?
      @post.photo.attach(params[:post][:photo])
    end

    if @post.save
      redirect_to root_path, notice: 'Post was successfully created.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      redirect_to root_path, notice: 'Post was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
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
    @post = current_user.posts.find(params[:id])  # Намираме поста само за текущия потребител
  end

  def post_params
    params.require(:post).permit(:title, :description, :post_date, :photo)
  end
end

# frozen_string_literal: true
# require 'pp'

class PostsController < ApplicationController
  include Sortable
  before_action :authenticate_user!
  before_action :set_post, only: %i[edit update destroy]

  def edit
    # Не е необходимо да вземаш поста, защото го вземаме в before_action
  end

  def show
    @post = Post.find(params[:id])
    @post.increment!(:views_count)
    @comments = @post.comments.includes(:user).paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
    @total_comments_count = @post.comments.count
    @comment = Comment.new
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Post not found'
  end

  def index
    # @posts = Post.paginate(:page => params[:page], :per_page => 3).order('created_at DESC')
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

    if @post.update(post_params)
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

  # def download_pdf
  #   Rails.application.routes.default_url_options[:host] = request.base_url
  #   post = Post.find(params[:id])
  #   post.increment!(:downloaded_as_pdf)
  #   pdf_generator = PostPdfGenerator.new(post) # Предполагам, че имаш подобен клас за един пост
  #   pdf_generator.generate_pdf
  #   send_file "#{Rails.root}/public/#{post.title.parameterize}_post.pdf", type: 'application/pdf', disposition: 'attachment'
  # end

  def download_pdf
    Rails.application.routes.default_url_options[:host] = request.base_url
    post = Post.find(params[:id])

    # Блокиране на повторно изпълнение на увеличаване, ако това вече е направено в рамките на последните секунди
    if session[:last_downloaded].present? && session[:last_downloaded] == post.id && session[:last_downloaded_at].present? && Time.now - session[:last_downloaded_at].to_time < 5
      # Ако условието е изпълнено, не правим нищо
    else
      post.increment!(:downloaded_as_pdf)
      if current_user != post.user
        NotificationService.notify(
          recipient: post.user,
          actor: current_user,
          action: 'downloaded',
          notifiable: post
        )
      end
      session[:last_downloaded] = post.id
      session[:last_downloaded_at] = Time.now
    end


    pdf_generator = PostPdfGenerator.new(post)
    pdf_generator.generate_pdf
    send_file "#{Rails.root}/public/#{post.title.parameterize}_post.pdf", type: 'application/pdf', disposition: 'attachment'
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

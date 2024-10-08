# frozen_string_literal: true

class PostsController < ApplicationController
  include Sortable
  before_action :authenticate_user!
  before_action :set_post, only: %i[edit update destroy]
  before_action :check_blocked, only: %i[show download_pdf]

  def edit
    # Не е необходимо да вземаш поста, защото го вземаме в before_action
  end

  def show
    @post = Post.find(params[:id])
    @post.increment!(:views_count)
    @comments = @post.comments.includes(:user).paginate(page: params[:page], per_page: 10).order('created_at DESC')
    @total_comments_count = @post.comments.count
    @comment = Comment.new
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Post not found'
  end

  def index
    # Постовете се зареждат чрез модула Sortable
  end

  def create
    @post = current_user.posts.build(post_params) # Създаваме поста за текущия потребител

    @post.photo.attach(params[:post][:photo]) if params[:post][:photo].present?

    if @post.save
      redirect_to root_path, notice: 'Post was successfully created.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: 'Post was successfully updated.'
    else
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

  def download_pdf
    Rails.application.routes.default_url_options[:host] = request.base_url
    post = Post.find(params[:id])

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

  def check_blocked
    @post = Post.find(params[:id])
    if current_user.blocking?(@post.user) || @post.user.blocking?(current_user)
      redirect_to root_path, alert: 'You cannot interact with posts from this user.'
    end
  end
end

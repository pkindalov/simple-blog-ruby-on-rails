# frozen_string_literal: true
class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:list, :popular] # Позволете неавтентифицирани потребители да виждат популярни и списъци
  before_action :set_user, only: [:show, :profile, :settings, :update, :delete_avatar, :followers, :following]
  before_action :check_blocked, except: [:list, :popular, :profile] # Позволете достъп до profile, дори когато сте блокирани

  def show
    # set_user вече задава @user
  end

  def profile
    if current_user.blocking?(@user) || @user.blocking?(current_user)
      # Ако сте блокирани, скрийте съдържанието и покажете само бутоните за (от)блокиране
      @posts = []
      @comments = []
    else
      @posts = @user.posts.paginate(page: params[:page], per_page: 10)
      @comments = @user.comments.paginate(page: params[:comments_page], per_page: 10)
    end
  end

  def settings
    # settings view-то използва settings.html.erb
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :profile } # Показване на формата за профил с грешки
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete_avatar
    @user.avatar.purge
    redirect_to user_profile_path(@user), notice: 'Avatar successfully removed.'
  end

  def download_posts_pdf
    Rails.application.routes.default_url_options[:host] = request.base_url
    user = User.find(params[:id])
    pdf_generator = UserPostsPdfGenerator.new(user)
    pdf_generator.generate_pdf
    send_file "#{Rails.root}/public/#{user.email}_posts.pdf", type: 'application/pdf', disposition: 'attachment'
  end

  def followers
    @followers = @user.followers.paginate(page: params[:page], per_page: 10)
  end

  def following
    @following = @user.following.paginate(page: params[:page], per_page: 10)
  end

  def popular
    @popular_users = User.all.sort_by { |user| -user.popularity_score }.first(10) # Взема първите 10 най-популярни потребители
  end

  def list
    @users = User.all.paginate(page: params[:page], per_page: 10)
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'User not found.'
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :avatar)
  end

  def check_blocked
    return unless @user && current_user # Уверете се, че @user и current_user са зададени

    # Пренасочване само ако не сме на страницата profile
    if action_name != 'profile' && (current_user.blocking?(@user) || @user.blocking?(current_user))
      redirect_to root_path, alert: 'You cannot interact with this user.'
    end
  end
end

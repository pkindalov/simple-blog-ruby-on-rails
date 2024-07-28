# frozen_string_literal: true
class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show, :profile, :settings, :update, :delete_avatar]
  before_action :set_user, only: [:show, :profile, :settings, :update, :delete_avatar]

  def show
    # set_user вече задава @user
  end

  def profile
    @posts = @user.posts.paginate(page: params[:page], per_page: 10)
    @comments = @user.comments.paginate(page: params[:comments_page], per_page: 10)
    # @posts = @user.posts.paginate(page: params[:page], per_page: 5)
  end

  def settings
    # settings view-то използва settings.html.erb
  end

  # def update
  # respond_to do |format|
  #   if @user.update(user_params)
  #     format.html { redirect_to @user, notice: 'User was successfully updated.' }
  #     format.json { render :show, status: :ok, location: @user }
  #   end
  # end
  # end

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

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # redirect_to controller: 'home', action: 'index'
    redirect_to root_path, alert: 'User not found.'
    # return
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :avatar)
  end
end

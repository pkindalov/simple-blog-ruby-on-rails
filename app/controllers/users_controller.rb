# frozen_string_literal: true
class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show, :profile, :settings, :update]
  before_action :set_user, only: [:show, :profile, :settings, :update]

  def show
    # set_user вече задава @user
  end

  def profile
    @posts = @user.posts.paginate(page: params[:page], per_page: 5)
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

# frozen_string_literal: true
# app/controllers/follows_controller.rb
class FollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :check_blocked, only: %i[create destroy]

  def create
    follow = current_user.follow(@user) # Създава следване

    if follow.persisted?
      NotificationService.notify(
        recipient: @user,
        actor: current_user,
        action: 'follow',
        notifiable: follow
      )
    end

    redirect_to user_profile_path(@user), notice: 'You are now following this user.'
  end

  def destroy
    unfollow = current_user.unfollow(@user)

    if unfollow
      NotificationService.notify(
        recipient: @user,
        actor: current_user,
        action: 'unfollow',
        notifiable: unfollow
      )
    end

    redirect_to user_profile_path(@user), notice: 'You have unfollowed this user.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def check_blocked
    if current_user.blocking?(@user) || @user.blocking?(current_user)
      redirect_to user_profile_path(@user), alert: 'You cannot follow or unfollow this user.'
    end
  end
end

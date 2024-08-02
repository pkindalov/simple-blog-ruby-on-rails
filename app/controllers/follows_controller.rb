# app/controllers/follows_controller.rb
class FollowsController < ApplicationController
  before_action :set_user

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
end

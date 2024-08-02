# app/controllers/follows_controller.rb
class FollowsController < ApplicationController
  before_action :set_user

  def create
    current_user.follow(@user)
    redirect_to user_profile_path(@user), notice: 'You are now following this user.'
  end

  def destroy
    current_user.unfollow(@user)
    redirect_to user_profile_path(@user), notice: 'You have unfollowed this user.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end

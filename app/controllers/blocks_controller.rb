# frozen_string_literal: true

class BlocksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def create
    current_user.block(@user)
    redirect_to user_profile_path(@user), notice: 'User has been blocked.'
  end

  def destroy
    current_user.unblock(@user)
    redirect_to user_profile_path(@user), notice: 'User has been unblocked.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end

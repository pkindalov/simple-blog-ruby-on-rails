# frozen_string_literal: true

module PostsHelper
  def already_liked?(post)
    # Like.where(user_id: current_user.id, post_id: post.id).exists?
    current_user && post.likes.exists?(user_id: current_user.id)
  end
end

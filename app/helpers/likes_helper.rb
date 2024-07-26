module LikesHelper
  def already_liked?(user, likeable)
    user.likes.where(likeable: likeable).exists?
    # liked = user.likes.where(likeable: likeable).exists?
    # Rails.logger.debug "Checking already_liked?: User #{user.id}, Likeable #{likeable.id} #{likeable.class}, Result: #{liked}"
    # liked
  end
end

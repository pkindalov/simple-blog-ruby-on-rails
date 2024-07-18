module Sortable
  extend ActiveSupport::Concern

  included do
    before_action :load_sorted_posts, only: [:index]
  end

  private

  def load_sorted_posts
    @sort_by = params[:sort_by] || 'recent'

    @posts = case @sort_by
             when 'views'
               Post.paginate(page: params[:page], per_page: 5).order(views_count: :desc)
             when 'photos'
               Post.left_joins(:photos_attachments).group('posts.id')
                   .paginate(page: params[:page], per_page: 5)
                   .order('COUNT(active_storage_attachments.record_id) DESC')
                   .where(active_storage_attachments: { name: 'photos', record_type: 'Post' })
             when 'likes'
               Post.left_joins(:likes).group('posts.id')
                   .paginate(page: params[:page], per_page: 5)
                   .order('COUNT(likes.id) DESC')
             when 'author_asc'
               Post.joins(:user).paginate(page: params[:page], per_page: 5).order(email: :asc)
             when 'author_desc'
               Post.joins(:user).paginate(page: params[:page], per_page: 5).order(email: :desc)
             else # recent
               Post.paginate(page: params[:page], per_page: 5).order(created_at: :desc)
             end
  end
end

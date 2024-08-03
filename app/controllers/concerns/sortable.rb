# frozen_string_literal: true

module Sortable
  extend ActiveSupport::Concern

  included do
    before_action :load_sorted_posts, only: [:index]
  end

  private

  def load_sorted_posts
    return unless user_signed_in?

    @sort_by = params[:sort_by] || 'popular'

    # Извличане на идентификаторите на блокираните потребители
    blocked_user_ids = current_user.blocked_users.pluck(:id)

    # Извличане на всички постове, без тези на блокираните потребители
    @posts = Rails.cache.fetch("#{@sort_by}/all_posts/#{params[:page]}", expires_in: 10.minutes) do
      case @sort_by
      when 'popular'
        Post.where.not(user_id: blocked_user_ids)
            .select("posts.*, (COALESCE(posts.views_count, 0) + COALESCE(posts.downloaded_as_pdf, 0) + COALESCE(COUNT(likes.id), 0) + COALESCE(COUNT(comments.id), 0)) AS popularity_score")
            .left_joins(:likes, :comments)
            .group('posts.id')
            .order('popularity_score DESC')
            .paginate(page: params[:page], per_page: 5)
      when 'views'
        Post.where.not(user_id: blocked_user_ids)
            .paginate(page: params[:page], per_page: 5)
            .order(views_count: :desc)
      when 'photos'
        Post.where.not(user_id: blocked_user_ids)
            .left_joins(:photos_attachments)
            .group('posts.id')
            .paginate(page: params[:page], per_page: 5)
            .order('COUNT(active_storage_attachments.record_id) DESC')
            .where(active_storage_attachments: { name: 'photos', record_type: 'Post' })
      when 'likes'
        Post.where.not(user_id: blocked_user_ids)
            .left_joins(:likes)
            .group('posts.id')
            .paginate(page: params[:page], per_page: 5)
            .order('COUNT(likes.id) DESC')
      when 'comments'
        Post.where.not(user_id: blocked_user_ids)
            .left_joins(:comments)
            .group('posts.id')
            .paginate(page: params[:page], per_page: 5)
            .order('COUNT(comments.id) DESC')
      when 'author_asc'
        Post.where.not(user_id: blocked_user_ids)
            .joins(:user)
            .paginate(page: params[:page], per_page: 5)
            .order('users.email ASC')
      when 'author_desc'
        Post.where.not(user_id: blocked_user_ids)
            .joins(:user)
            .paginate(page: params[:page], per_page: 5)
            .order('users.email DESC')
      else
        Post.where.not(user_id: blocked_user_ids)
            .paginate(page: params[:page], per_page: 5)
            .order(created_at: :desc)
      end
    end

    # Извличане на постове на последваните потребители, които не са блокирани
    following_ids = current_user.following.pluck(:id) - blocked_user_ids

    @following_posts = Rails.cache.fetch("#{@sort_by}/following_posts/#{params[:page]}", expires_in: 10.minutes) do
      case @sort_by
      when 'popular'
        Post.where(user_id: following_ids)
            .select("posts.*, (COALESCE(posts.views_count, 0) + COALESCE(posts.downloaded_as_pdf, 0) + COALESCE(COUNT(likes.id), 0) + COALESCE(COUNT(comments.id), 0)) AS popularity_score")
            .left_joins(:likes, :comments)
            .group('posts.id')
            .order('popularity_score DESC')
            .paginate(page: params[:page], per_page: 5)
      when 'views'
        Post.where(user_id: following_ids)
            .paginate(page: params[:page], per_page: 5)
            .order(views_count: :desc)
      when 'photos'
        Post.where(user_id: following_ids)
            .left_joins(:photos_attachments)
            .group('posts.id')
            .paginate(page: params[:page], per_page: 5)
            .order('COUNT(active_storage_attachments.record_id) DESC')
            .where(active_storage_attachments: { name: 'photos', record_type: 'Post' })
      when 'likes'
        Post.where(user_id: following_ids)
            .left_joins(:likes)
            .group('posts.id')
            .paginate(page: params[:page], per_page: 5)
            .order('COUNT(likes.id) DESC')
      when 'comments'
        Post.where(user_id: following_ids)
            .left_joins(:comments)
            .group('posts.id')
            .paginate(page: params[:page], per_page: 5)
            .order('COUNT(comments.id) DESC')
      when 'author_asc'
        Post.where(user_id: following_ids)
            .joins(:user)
            .paginate(page: params[:page], per_page: 5)
            .order('users.email ASC')
      when 'author_desc'
        Post.where(user_id: following_ids)
            .joins(:user)
            .paginate(page: params[:page], per_page: 5)
            .order('users.email DESC')
      else
        Post.where(user_id: following_ids)
            .paginate(page: params[:page], per_page: 5)
            .order(created_at: :desc)
      end
    end
  end
end

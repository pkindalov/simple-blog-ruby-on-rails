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

    # Извличане на всички постове
    @posts = Rails.cache.fetch("#{@sort_by}/all_posts/#{params[:page]}", expires_in: 10.minutes) do
      case @sort_by
      when 'popular'
        Post.select("posts.*, (COALESCE(posts.views_count, 0) + COALESCE(posts.downloaded_as_pdf, 0) + COALESCE(COUNT(likes.id), 0) + COALESCE(COUNT(comments.id), 0)) AS popularity_score")
            .left_joins(:likes, :comments)
            .group('posts.id')
            .order('popularity_score DESC')
            .paginate(page: params[:page], per_page: 5)
      when 'views'
        Post.paginate(page: params[:page], per_page: 5).order(views_count: :desc)
      when 'photos'
        Post.left_joins(:photos_attachments)
            .group('posts.id')
            .paginate(page: params[:page], per_page: 5)
            .order('COUNT(active_storage_attachments.record_id) DESC')
            .where(active_storage_attachments: { name: 'photos', record_type: 'Post' })
      when 'likes'
        Post.left_joins(:likes)
            .group('posts.id')
            .paginate(page: params[:page], per_page: 5)
            .order('COUNT(likes.id) DESC')
      when 'comments'
        Post.left_joins(:comments)
            .group('posts.id')
            .paginate(page: params[:page], per_page: 5)
            .order('COUNT(comments.id) DESC')
      when 'author_asc'
        Post.joins(:user)
            .paginate(page: params[:page], per_page: 5)
            .order('users.email ASC')
      when 'author_desc'
        Post.joins(:user)
            .paginate(page: params[:page], per_page: 5)
            .order('users.email DESC')
      else
        Post.paginate(page: params[:page], per_page: 5).order(created_at: :desc)
      end
    end

    # Извличане на постове на последваните потребители
    following_ids = current_user.following.pluck(:id)

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

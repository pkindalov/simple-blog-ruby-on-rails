# frozen_string_literal: true

class HomeController < ApplicationController
  include Sortable
  def index
    # @sort_by = params[:sort_by] || 'recent'
    #
    # @posts = case @sort_by
    #          when 'views'
    #            Post.paginate(page: params[:page], per_page: 3).order(views_count: :desc)
    #          when 'photos'
    #            Post.left_joins(:photos_attachments)
    #                .group('posts.id').paginate(page: params[:page], per_page: 3)
    #                .order('COUNT(active_storage_attachments.record_id) DESC')
    #                .where(active_storage_attachments: { name: 'photos', record_type: 'Post' })
    #          when 'likes'
    #            Post.left_joins(:likes)
    #                .group('posts.id')
    #                .paginate(page: params[:page], per_page: 3)
    #                .order('COUNT(likes.id) DESC')
    #          else
    #            # 'recent' or default case
    #            Post.paginate(page: params[:page], per_page: 3).order(created_at: :desc)
    #          end

    # @posts = Post.paginate(:page => params[:page], :per_page => 3).order('created_at DESC')
  end

  def about; end

  def services; end

  def contacts; end
end

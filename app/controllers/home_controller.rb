class HomeController < ApplicationController
  def index
    @posts = Post.paginate(:page => params[:page], :per_page => 3).order('created_at DESC')
  end

  def about
  end

  def services
  end

  def contacts
  end
end

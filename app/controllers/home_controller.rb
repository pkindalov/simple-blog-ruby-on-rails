class HomeController < ApplicationController
  def index
    @posts = Post.all
  end

  def about
  end

  def services
  end

  def contacts
  end
end

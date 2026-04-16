class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    render "home/index"
  end
end

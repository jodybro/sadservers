class HomeController < ApplicationController
  def index
    @message = "Welcome to the Rails Docker Optimization Demo!"
    @timestamp = Time.current
  end
end
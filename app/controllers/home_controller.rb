class HomeController < ApplicationController
  skip_before_filter :require_login

  def index
  end

  def features
  end

  def getting_started
  end
end

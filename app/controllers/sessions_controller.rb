class SessionsController < ApplicationController
  skip_before_filter :require_login, :except => [:destroy]
  skip_before_filter :verify_authenticity_token, :only => [:client_login, :client_logout]

  def new
  end

  def client_login
    if user = login(params[:email], params[:password], true)
      render :text => "ok"
    else
      render :text => "error"
    end
  end

  def client_logout
    logout
    render :text => "ok"
  end

  def create
    respond_to do |format|
      if @user = login(params[:sessions][:email], params[:sessions][:password], params[:sessions][:remember])
        flash[:success] = I18n.t(:signed_in, :username => @user.username.present? ? @user.username : @user.email )
        format.html {redirect_back_or_to account_path}
        format.js
      else
        format.html {@user = User.new; flash.now.alert = I18n.t(:unsuccessful_auth); render :action => "new"}
        format.js
      end
    end
  end

  def destroy
    logout
    flash[:success] = I18n.t(:signed_out)
    redirect_to root_path
  end
end

class UsersController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create, :subscribe, :unsubscribe, :password_hint]
  skip_before_filter :verify_authenticity_token, :only => [:subscribe, :unsubsribe]

  def index
    authorize! :manage, User
    respond_to do |format|
      format.html
      format.json {render json: UsersDatatable.new(view_context, current_user)}
    end
  end

  def authorize_dropbox
    if not params[:oauth_token]
      dropbox_session = DropboxSession.new(APP_KEY, APP_SECRET)
      session[:dropbox_session] = dropbox_session.serialize
      redirect_to dropbox_session.get_authorize_url(CustomHelper.app_url(request) + "/users/authorize_dropbox")
    else
      dropbox_session = DropboxSession.deserialize(session[:dropbox_session])
      access_token = dropbox_session.get_access_token
      current_user.dropbox_access_token = dropbox_session.serialize
      current_user.save
      session[:dropbox_session] = dropbox_session.serialize
      flash[:success] = I18n.t(:authorized)
      redirect_to account_path
    end
  end

  def password_hint
    message = I18n.t(:email_not_found)
    @user = User.find_by_email(params[:email])
    if @user
      message = I18n.t(:your_password_hint_is) + "\n" + @user.password_hint
    end
    render :json => {"message" => message}
  end

  def disable_dropbox
    @user = User.find(params[:id])
    @user.dropbox_access_token = ""
    @user.save
    html = render_to_string :partial => "dropbox"
    render :json => {"html" => html}
  end

  def new
  end

  def create
    @user = User.new
    @user.attributes = params[:user]
    password = params[:user][:password]
    if @user.save
      p "sending invitation email" if Rails.env.eql?("development")
      QC.enqueue("User.deliver_signup_confirmation", @user.id)
      user = login(@user.email, password, true)
      flash[:success] = I18n.t(:signed_up)
      respond_to do |format|
        format.html {redirect_to account_path}
        format.js
      end
      
    else
      flash.now[:error] = I18n.t(:validation_errors, :scope => [:activerecord, :errors])
      @ajax_html = render_to_string :new_modal, :layout => false
      respond_to do |format|
        format.html {render :new}
        format.js
      end
    end
  end

  def show
    @user = current_user
    @admin = can? :manage, @user
  end

  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        @ajax_html = render_to_string :partial => "edit_account", :layout => false
        @flash = I18n.t(:successfully_updated, :scope => [:activerecord])
        format.html {redirect_to account_path, :notice => @flash}
        format.js
      else
        p @user.errors.messages.has_key?(:password_hint)
        @flash = I18n.t(:validation_errors, :scope => [:activerecord, :errors])
        @ajax_html = render_to_string :partial => "edit_account", :layout => false
        format.html do 
          flash.now.alert = @flash
          render :show
        end
        format.js
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    authorize! :manage, @user
    @user.destroy
    render :json => {"status" => "ok"}
  end

  def toggle_admin
    @user = User.find(params[:id])
    authorize! :mananage, @user
    @user.admin = !@user.admin
    @user.save
    html = render_to_string :partial => "toggle_admin", :locals => {:user => @user}
    render :json => {"status" => "ok", "html" => html}
  end

  def subscribe
    user = User.new(:email => params[:email], :password => params[:password])
    if user.save
      render :text => "ok"
    else
      render :text => "error"
    end
  end
  
  def unsubscribe
    user = login(params[:email], params[:password])
    if user
      user.destroy
      render :text => "ok"
    else
      render :text => "error"
    end
  end
end

class PasswordResetsController < ApplicationController
  skip_before_filter :require_login
  def create
    @user = User.find_by_email(params[:email])
    @user.deliver_reset_password_instructions! if @user
    message = I18n.t(:reset_password_instructions_sent)
    respond_to do |format|
      format.html do
        flash[:success] = message
        redirect_to root_path
      end
      format.json {render :json => {"message" => message}}
    end
  end

  def edit
    @user = User.load_from_reset_password_token(params[:id])
    @token = params[:id]
    not_authenticated unless @user
  end

  def update
    @token = params[:token]
    @user = User.load_from_reset_password_token(params[:token])
    not_authenticated unless @user
    if @user.change_password!(params[:user][:password])
      @user.password_hint = params[:user][:password_hint]
      @user.save
      flash[:success] = I18n.t(:password_changed)
      redirect_to root_path
    else
      flash.now[:error] = I18n.t(:validation_errors, :scope => [:activerecord, :errors])
      render :action => "edit"
    end
  end
end

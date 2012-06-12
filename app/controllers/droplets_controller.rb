class DropletsController < ApplicationController
  skip_before_filter :require_login, :only => [:upload, :create, :index, :update, :destroy, :show, :basic_auth_login, :confirm, :sync, :pending]
  skip_before_filter :verify_authenticity_token
  before_filter :require_login_from_http_basic, :only => [:basic_auth_login]

  def basic_auth_login
    render :text => "Login from basic auth successful!"
  end

  def index
    if current_user
      user = current_user
    else
      user = login(params[:email], params[:password], true)
    end
    if user
      @droplets = Droplet.where(:user_id => user.id)
      respond_to do |format|
        format.html
        format.json { render json: @droplets }
      end
    else
      flash[:warning] = I18n.t(:auth_required)
      redirect_to signin_path
    end
  end

  def html_index
    respond_to do |format|
      format.html
      format.json {render json: DropletsDatatable.new(view_context, current_user)}
    end
  end

  def show
    if current_user
      user = current_user
    else
      user = login(params[:email], params[:password], true)
    end
    if user
      @droplet = Droplet.find(params[:id])
      respond_to do |format|
        format.html
        format.json { render json: @droplet }
      end
    else
      flash[:warning] = I18n.t(:auth_required)
      redirect_to signin_path
    end
  end

  def new
    @droplet = Droplet.new

    respond_to do |format|
      format.html
      format.json { render json: @droplet }
    end
  end

  def edit
    @droplet = Droplet.find(params[:id])
  end

  def create
    if current_user
      user = current_user
    else
      user = login(params[:email], params[:password], true)
    end
    if user
      @droplet = Droplet.new(params[:droplet])
      @droplet.url = params[:url] if params[:url].present?
      @droplet.user ||= user
      @droplet.status ||= Status.find_by_name("pending")

      respond_to do |format|
        if @droplet.save
          format.html { redirect_to @droplet, notice: 'Droplet was successfully created.' }
          format.json { render json: @droplet, status: :created, location: @droplet }
        else
          format.html { render action: "new" }
          format.json { render json: @droplet.errors, status: :unprocessable_entity }
        end
      end
    else
      flash[:warning] = I18n.t(:auth_required)
      redirect_to signin_path
    end
  end

  def update
    if current_user
      user = current_user
    else
      user = login(params[:email], params[:password], true)
    end
    if user
      @droplet = Droplet.find(params[:id])
      @droplet.user ||= user

      respond_to do |format|
        if @droplet.update_attributes(params[:droplet])
          format.html { redirect_to @droplet, notice: 'Droplet was successfully updated.' }
          format.json { head :ok }
        else
          format.html { render action: "edit" }
          format.json { render json: @droplet.errors, status: :unprocessable_entity }
        end
      end
    else
      flash[:warning] = I18n.t(:auth_required)
      redirect_to signin_path
    end
  end

  def destroy
    if current_user
      user = current_user
    else
      user = login(params[:email], params[:password], true)
    end
    if user
      @droplet = Droplet.find(params[:id])
      @droplet.user = @current_user
      @droplet.status = Status.find_by_name("removed")
      @droplet.save

      respond_to do |format|
        format.html { redirect_to droplets_url }
        format.json { head :ok }
      end
    else
      flash[:warning] = I18n.t(:auth_required)
      redirect_to signin_path
    end
  end
  
  def pending
    if current_user
      user = current_user
    else
      user = login(params[:email], params[:password], true)
    end
    if user
      downloaded_id = Status.find_by_name("downloaded").id
      synched_id = Status.find_by_name("synched").id
      droplets = Droplet.select([:id, :name]).where(:status_id => [downloaded_id, synched_id], :user_id => user.id).all
      render :json => {:droplets => droplets}.to_json
    else
      flash[:warning] = I18n.t(:auth_required)
      redirect_to signin_path
    end
  rescue
    render :text => "error"
  end
  
  def synch
    if current_user
      user = current_user
    else
      user = login(params[:email], params[:password], true)
    end
    if user
      downloaded_id = Status.find_by_name("downloaded").id
      synched_id = Status.find_by_name("synched").id
      droplet = Droplet.where(:id => params[:id], :user_id => user.id, :status_id => [downloaded_id, synched_id]).first
      raise if droplet.nil?
      droplet.synch
      send_file droplet.file, :x_sendfile=>true
    else
      flash[:warning] = I18n.t(:auth_required)
      redirect_to signin_path
    end
    rescue
      render :text => "error"
  end
  
  def confirm
    if current_user
      user = current_user
    else
      user = login(params[:email], params[:password], true)
    end
    if user
      droplet = Droplet.where(:id => params[:id], :user_id => user.id, :status_id => Status.find_by_name("synched").id).first
      raise if droplet.nil?
      droplet.confirm
      droplet.file = ""
      droplet.update_status("removed")
      render :text => "ok"
    else
      flash[:warning] = I18n.t(:auth_required)
      redirect_to signin_path
    end
  rescue
    render :text => "error"
  end

  def upload
    if current_user
      user = current_user
    else
      user = login(params[:email], params[:password], true)
    end
    if user
      @droplet = Droplet.new()
      @droplet.user = current_user
      if params.has_key? :force
        params.each{|param| @file = param[1] if param[1].is_a? ActionDispatch::Http::UploadedFile }
        @droplet.upload(params[:name], @file)
      else
        @droplet.upload(params[:name], params[:data])
      end
      render :text => "ok"
    else
      raise
    end
  rescue
    render :text => "error"
  end
  
end

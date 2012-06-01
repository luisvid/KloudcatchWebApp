class ContactsController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create]

  def index
    authorize! :manage, Contact
    respond_to do |format|
      format.html
      format.json {render json: ContactsDatatable.new(view_context)}
    end
  end

  def new
    @contact = Contact.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @contact }
    end
  end

  def create
    @contact = Contact.new(params[:contact])

    respond_to do |format|
      if @contact.save
        flash[:success] = I18n.t(:contact_received)
        format.html { redirect_to app_path }
      else
        flash.now[:error] = I18n.t(:validation_errors, :scope => [:activerecord, :errors])
        format.html { render action: "new" }
      end
    end
  end


  def destroy
    @contact = Contact.find(params[:id])
    authorize! :manage, @contact
    @contact.destroy

    respond_to do |format|
      format.json {render :json => {"status" => "ok"}}
    end
  end
end

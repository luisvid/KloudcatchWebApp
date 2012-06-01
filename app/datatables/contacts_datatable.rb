class ContactsDatatable
  delegate :params, :h, :l, :t, :link_to, :number_to_currency, :sanitize, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Contact.count,
      iTotalDisplayRecords: contacts.total_entries,
      aaData: data
    }
  end

  private
  
  def data
    contacts.map do |contact|
      [
        h( l contact.created_at, :format => :long),
        h(contact.name),
        h(contact.email),
        h(contact.phone),
        h(sanitize contact.message),
        "<div title='#{sanitize contact.message}'>#{sanitize contact.message.truncate(50)}</div>".html_safe,
        "<div class='btn-group'><a class='btn btn-mini details' href='#' rel='tooltip' title='#{I18n.t(:show_message, :scope => [:tooltips])}'><i class='icon-zoom-in'></i> #{I18n.t(:show)}</a><a class='btn btn-mini delete' href='#' rel='tooltip' title='#{I18n.t(:delete_contact, :scope => [:tooltips])}' data-url='/contacts/#{contact.id}' data-confirm='#{I18n.t(:delete_record, :scope => [:confirms])}'><i class='icon-trash'></i> #{I18n.t(:delete)}</a></div>".html_safe
      ]
    end
  end

  def contacts
    @contacts ||= fetch_contacts
  end

  def fetch_contacts
    contacts = Contact.order("#{sort_column} #{sort_direction}")
    contacts = contacts.page(page).per_page(per_page)
    if params[:sSearch].present?
      contacts = contacts.where("name @@ :search or email @@ :search or phone @@ :search or message @@ :search", search: params[:sSearch])
    end
    contacts
  end
  
  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[created_at name email phone message message created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end

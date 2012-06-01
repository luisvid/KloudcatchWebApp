class DropletsDatatable
  delegate :params, :truncate, :h, :l, :t, :link_to, :number_to_currency, :sanitize, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Droplet.where(:user_id => @current_user.id).count,
      iTotalDisplayRecords: droplets.total_entries,
      aaData: data
    }
  end

  private
  
  def data
    droplets.map do |droplet|
      [
        "<span title='#{droplet.url}'>#{h(truncate(droplet.url, :length => 30))}</span>",
        "<span title='#{droplet.name}'>#{h(truncate(droplet.name, :length => 30, :omission => "...(#{droplet.name.present? ? File.extname(droplet.name) : ""})"))}</span>",
        h(droplet.storage),
        "<span title='#{I18n.t(droplet.status.name.to_sym, :scope => [:tooltips, :statuses])}'>#{I18n.t(droplet.status.name.to_sym, :scope => [:activerecord, :statuses])}</span>".html_safe
      ]
    end
  end

  def droplets
    @droplets ||= fetch_droplets
  end

  def fetch_droplets
    droplets = Droplet.where(:user_id => @current_user.id).order("#{sort_column} #{sort_direction}")
    droplets = droplets.page(page).per_page(per_page)
    if params[:sSearch].present?
      droplets = droplets.where("url @@ :search or name @@ :search or storage @@ :search", search: params[:sSearch])
    end
    droplets
  end
  
  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[url name storage status_id]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end

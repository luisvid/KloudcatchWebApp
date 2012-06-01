class UsersDatatable
  delegate :params, :h, :l, :t, :link_to, :number_to_currency, :sanitize, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: User.count,
      iTotalDisplayRecords: users.total_entries,
      aaData: data
    }
  end

  private
  
  def data
    users.map do |user|
      [
        h(user.username),
        h(user.email),
        h(l user.created_at, :format => :short),
        unless user.id == @current_user.id
          "<div class='btn-group'><a class='btn btn-mini delete' href='#' rel='tooltip' title='#{I18n.t(:delete_user, :scope => [:tooltips])}' data-url='/users/#{user.id}' data-confirm='#{I18n.t(:delete_record, :scope => [:confirms])}'><i class='icon-trash'></i> #{I18n.t(:delete)}</a><a class='btn btn-mini toggle_admin' href='#' rel='tooltip' title='#{user.admin? ? I18n.t(:remove_admin_role, :scope => [:tooltips]): I18n.t(:add_admin_role, :scope => [:tooltips])}' data-url='/users/#{user.id}/toggle_admin' data-confirm='#{I18n.t(:toggle_admin, :scope => [:confirms])}'><i class='icon-#{user.admin? ? "minus" : "plus"}-sign'></i> #{I18n.t(:admin)}</a></div>".html_safe
        else
          ""
        end
      ]
    end
  end

  def users
    @users = fetch_users
  end

  def fetch_users
    users = User.order("#{sort_column} #{sort_direction}")
    users = users.page(page).per_page(per_page)
    if params[:sSearch].present?
      users = users.where("username @@ :search or email @@ :search", search: params[:sSearch])
    end
    users
  end
  
  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[username email created_at username]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end

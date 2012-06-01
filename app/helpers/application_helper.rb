module ApplicationHelper
  def active_main_menu(name, action=nil)
    state = nil
    if action.present?
      state = "active" if controller.controller_name == name && controller.action_name == action
    else
      state = "active" if controller.controller_name == name
    end 
    return state
  end

  def static_content
    if controller.controller_name == "home"
      return true
    else
      return false
    end
  end

end

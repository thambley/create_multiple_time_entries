module RedmineMultiuserTimelog
  module Hooks
    class TimelogHooks < Redmine::Hook::ViewListener
      
      render_on :view_timelog_edit_form_bottom, :partial => 'timelog/users'
      
    end
  end
end

module RedmineMultiuserTimelog
  module Hooks
    class TimelogHooks < Redmine::Hook::ViewListener
      
      render_on :view_timelog_edit_form_bottom, :partial => 'timelog/users'
      def view_timelog_edit_form_bottom(context = {})
        time_entry = context[:time_entry]
        form = context[:form]
        
        link_options = {
            :controller => :bulk_time_entries, 
            :action => :new,
            :only_path => true}
        if time_entry.issue
          link_options[:issue_id] = time_entry.issue
        else
          link_options[:project_id] = time_entry.project
        end
        time_entry.new_record? && time_entry.project && User.current.allowed_to?(link_options, time_entry.project) ?
          content_tag("p",link_to(l(:label_multiuser_timelog), link_options)) :
          ""
      end
    end
  end
end

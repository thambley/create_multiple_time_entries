require 'timelog_helper'

module RedmineMultiuserTimelog
  module Patches
    module TimelogHelperPatch

      def user_collection_for_select_options(project, selected = nil)
        collection =  project.members.map{|member| member.user }.sort
        collection.keep_if{|user| user.allowed_to?(:log_time, project)}    
        
        s = ''
        
        collection.sort.each do |element|
          selected_attribute = ' selected="selected"' if option_value_selected?(element, selected)
          s << %(<option value="#{element.id}"#{selected_attribute}>#{h element.name}</option>)
        end
        
        s.html_safe
      end
      
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless TimelogHelper.included_modules.include?(RedmineMultiuserTimelog::Patches::TimelogHelperPatch)
    TimelogHelper.send(:include, RedmineMultiuserTimelog::Patches::TimelogHelperPatch)
  end
end

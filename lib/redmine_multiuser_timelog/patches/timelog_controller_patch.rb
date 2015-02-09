#require 'TimelogController'

module RedmineMultiuserTimelog
  module Patches
    module TimelogControllerPatch

      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          alias_method_chain :create, :multiuser_timelog
        end
      end

      module InstanceMethods
      
        def create_with_multiuser_timelog
          #logger.info "create_with_multiuser_timelog #{params[:time_entry][:user_ids]}"
          if request.post? and User.current.allowed_to?(:manage_time_entries, @project)
            @time_entry ||= MultiuserTimeEntry.new(:project => @project)
            time_entry_params = params[:time_entry]
            if params.has_key?(:multiuser_time_entry)
              time_entry_params.merge!(params[:multiuser_time_entry])
            end
            @time_entry.safe_attributes = time_entry_params
                
            if @time_entry.save { |time_entry| call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => time_entry })}
               respond_to do |format|
                format.html {
                  flash[:notice] = l(:notice_successful_create)
                  if params[:continue]
                    if params[:project_id]
                      options = {
                        :time_entry => {:issue_id => @time_entry.issue_id, :activity_id => @time_entry.activity_id},
                        :back_url => params[:back_url]
                      }
                      if @time_entry.issue
                        redirect_to new_project_issue_time_entry_path(@time_entry.project, @time_entry.issue, options)
                      else
                        redirect_to new_project_time_entry_path(@time_entry.project, options)
                      end
                    else
                      options = {
                        :time_entry => {:project_id => @time_entry.project_id, :issue_id => @time_entry.issue_id, :activity_id => @time_entry.activity_id},
                        :back_url => params[:back_url]
                      }
                      redirect_to new_time_entry_path(options)
                    end
                  else
                    redirect_back_or_default project_time_entries_path(@time_entry.project)
                  end
                }
                format.api  { render :action => 'show', :status => :created, :location => time_entry_url(@time_entry) }
              end
            else
              respond_to do |format|
                format.html { render :action => 'new' }
                format.api  { render_validation_errors(@time_entry) }
              end
            end    
          else
            create_without_multiuser_timelog
          end
        end
        
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless TimelogController.included_modules.include?(RedmineMultiuserTimelog::Patches::TimelogControllerPatch)
    TimelogController.send(:include, RedmineMultiuserTimelog::Patches::TimelogControllerPatch)
  end
end

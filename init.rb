ActionDispatch::Callbacks.to_prepare do
    # use require_dependency if you plan to utilize development mode
    require 'redmine_multiuser_timelog/hooks/timelog_hooks'
end

Redmine::Plugin.register :redmine_multiuser_timelog do
  name 'Multiple User Timelog plugin'
  author 'Integra Consultores, Todd Hambley'
  description 'This plugin allows an authorized user to log time for multiple users simultaneously'
  version '0.0.1'
  url 'https://github.com/thambley/redmine_multiuser_timelog'
  author_url 'https://github.com/thambley'
  
  project_module :time_tracking do
    permission :manage_time, {:timelog => [:new, :create]}, :require => :member
  end
end

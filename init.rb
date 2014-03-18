require 'redmine'

require 'redmine_multiuser_timelog/hooks/timelog_hooks'
require 'redmine_multiuser_timelog/patches/timelog_helper_patch'

Redmine::Plugin.register :redmine_multiuser_timelog do
  name 'Multiple User Timelog plugin'
  author 'Integra Consultores, Todd Hambley'
  description 'This plugin allows an authorized user to log time for multiple users simultaneously'
  version '0.0.1'
  url 'https://github.com/thambley/redmine_multiuser_timelog'
  author_url 'https://github.com/thambley'
  
  project_module :time_tracking do
    permission :manage_time_entries, {:timelog => [:new, :create]}, :require => :member
  end
end
